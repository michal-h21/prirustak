-- Potřebujeme udělat seznam všech jednotak signatury F od 1 do 4549
--

if arg[1] == nil or arg[1] == "--help" or arg[1] == "-h" then
	print [[
	Použití: texlua katedr_diplomky.lua <vstupní soubor> rok [katedra] 
	]]
	os.exit(1)
end	

local lower = unicode.utf8.lower

local function load_katedry()
	local t = {}
	local l = {}
	for line in io.lines("katedry.tsv") do
		local c = line:explode("\t")
		local katl, kats = lower(c[1] or ""),c[2]
		t[katl]=kats
		l[kats]=katl
	end
	return t,l
end
local parser= require "parse_prir"
local sort = require "sort"
local remove = require "removeaccents"
local input = arg[1]
local proc_year = arg[2] or 2013
local proc_year_short = proc_year:sub(3)
local proc_kat = arg[3]
local f = parser.load_file(input)
local kat_short, kat_long  = load_katedry()
local diplout = "diplout/"
local pos = parser.find_pos(f,
  {"is-loan", "z30-item-status","z30-call-no", "z30-barcode", "bib-info","z13-year","z13u-user-defined-10","z13u-user-defined-3"})
parser.make_saves(pos)

local zaz = parser.parse(f)

local katedry = {}
for _,x in ipairs(zaz) do
	local kato = x["z13u-user-defined-10"] or ""
	local year = x["z13-year"]
	if kato ~=""  and year==proc_year then
		local typ, kat = kato:match("([^%:]+): ([^%*]+)")
		-- ToDo: podívat se
		--kat = lower(kat:match("%s*(.+)%s*"))
		if kat and typ == "diplomové práce" then
			kat = lower(kat:gsub("^%s*",""):gsub("%s*$",""))
			local n = katedry[kat] or {}
			n[#n+1] = x
			katedry[kat] = n
		end
	end
end

local function save_file(name, txt)
	local f = io.open(name,"w")
	f:write(txt)
	f:close()
end

local function make_name(kat, yr)
	local kat = remove.strip_accents(lower(kat))
	return kat .. yr .. ".html"
end

local t = {}

for k,_ in pairs(katedry) do
	t[#t+1] =  k
end

table.sort(t)
local kat_tpl = [[
---
title: "Obhájené diplomové práce: {katlong}"
---
<h1>Obhájené diplomové práce: {katlong}</h1>
{records}
]]

local function make_katedra(kat_name, records)
	local k = kat_name
	local s = kat_short[k]
	local t = {}
	local f = {}
	if not records then return nil end
	for _,x in ipairs(records) do
		local z = x["z13u-user-defined-3"]
		local ck= x["z30-barcode"]
		local key, strany = z:match("##[^%#]+##([^%#]+)##([^%#]+)")
    print(z, key, strany)
		local replace = string.format("<a href='http://ckis.cuni.cz/F/?func=find-e&request=%s&find_scan_code=FIND_IDN&adjacent=N&local_base=CKS'>%%1</a> /",ck)
		--local replace = string.format("<a href='http://ckis.cuni.cz/F/?func=find-c&ccl_term=IDN+%%3D+%s&local_base=CKS'>%%1</a> /",ck)
		local nazev = key:gsub("([^%/]+)/",replace):gsub("%[rukopis%] ","")
		local bib = table.concat({nazev, strany}, ". ")
		local rec = string.format("<div class='record'>\n<p>%s</p>\n<span class='signatura'>%s</span>\n</div>", bib, x["z30-call-no"])
		t[key]= rec
		print(key, rec, bib)
		table.insert(f,key)
	end
	table.sort(f, sort.compare)
	print(s,#f)
	local j = {}
	for _, i in ipairs(f) do
		j[#j+1] = t[i]
	end
	local text = table.concat(j,"\n")
	local file = kat_tpl:gsub("{records}", text):gsub("{katlong}", s)
	local name = make_name(s, proc_year_short)
	save_file(diplout .. name, file)
end

for _,k in pairs(t) do
	local v = katedry[k]
	make_katedra(k,v)
	-- print(k, kat_short[k], #v)
end

local umatch = unicode.utf8.match
local first_letters = {K=true,C = true, ["Ú"] = true}



local function make_index(year)
	local tpl_f = io.open("kat_dipl.tpl","r")
	local tpl = tpl_f:read("*all")
	tpl_f:close()
	local result = tpl:gsub("<tr>(.-)</tr>", function(row) 
		-- získat název katedry
		local curr = row:match('<span class="z3">(.-)</span>')
		-- získáme i nesmyslný údaje, pokračovat jen když začnínají na K, C nebo Ú
		if curr and first_letters[umatch(curr,".")] or curr == '&nbsp;' then
			-- získat dlouhej název katedry
			local k = kat_long[curr]
			-- získat záznamy
			local z = katedry[k] or {}
			local count = #z
			local link_tpl = '<td width="50" valign="middle" align="center"><span class="z4">{count}</span></td>'
			local href = count > 0 and make_name(curr, proc_year_short) 
			-- pokud zpracováváme první řádek tabulky, jedná se o roky
			if curr == '&nbsp;' then count = tonumber(proc_year) end
			local link = link_tpl
			if href then
				local replace = string.format('<a href="%s">{count}</a>', href)
				link = link:gsub("{count}", replace)
			end
			local link = link:gsub("{count}",count)
			row =  row .. link
		end
		return '<tr>' ..  row .. '</tr>'
	end)
	save_file(diplout .. "index.html", result)
end

make_index(proc_year)


