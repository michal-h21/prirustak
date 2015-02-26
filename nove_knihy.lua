#!/usr/bin/env texlua
-- arg 1 xml soubor z alephu
-- arg 2 zpracovávaný měsíc ve tvaru měsíc-rok
local prir = require "parse_prir"
local lapp = require "lib.pl.lapp"
local lustache = require "lib.lustache.lustache"
local print_r = require "lib.print_r"

local args = lapp [[
Zpracování nových knih. Defaultně se zpracovávají nové knihy
-d,--dipl Diplomky
-r,--rekat Rekatalogizace
<input> (string) Vstupní xml soubor 
<date> (string) Zpracovávaný měsíc ve formát mm-yyyy
]]
local f = prir.load_file(args.input)
local zprac_mes,zprac_rok = args.date:match("([0-9]+)-([0-9]+)")
prir.make_saves {51, 65, 76, 36, 16, 10}
local code = "z30-barcode"
local inv_date = "z30-inventory-number-date"

local zaznamy = {}

-- print "Parsing"
local p =prir.parse(f)

-- print "Creating arrays"
for c,r in ipairs(p) do
	local f = r[code]
	local day, month, year = r[inv_date]:match("([0-9]+)/([0-9]+)/([0-9]+)")
	if year == zprac_rok and month == zprac_mes then
		local sig = r['z30-call-no']
		local prefix, num, suffix = sig:match "([0-9]*[a-zA-Z]+)([0-9/%-%.]+)([0-9a-zA-Zěščřžýáíéúůťďň]*)"
		-- suffix = suffix or "*"
		if not suffix or suffix == "" then suffix = "*" end
		num = num or "*"
		prefix = prefix or "*"
   	-- print(day, month, year, sig, prefix, num, suffix)
		local pismenka = zaznamy[prefix] or {}
		local cisla = pismenka[num] or {}
		cisla[suffix] = r
		pismenka[num] = cisla
		zaznamy[prefix] = pismenka
	end
	--table.insert(k, r[code])
end


function select_records(records, driver)
	local t = {}
	local selects= {
		["*"] = function(r) return r["*"] end,
		["!"] = function(r) for _,v in pairs(r) do return(v) end end
	}
	-- driver je pole, kde klíč je prefix signatury a hodnota 
	-- je pole s řídícíma polema
	for pref, d in pairs(driver) do
		-- zpracováváme jednotlivý prefixy
		local d = d or {}
		-- minimální hodnota zpracovávaný signatury
		local min = d["min"]
		-- maximální zpracovávaná hodnota signatury
		local max = d["max"]
		-- zpracovávat jen pokud je nastavený klíč
		local key = d["key"]
		-- nezpracovávat pokud je nastavený klíč
		local stop = d["stop"]
		local sel = d["select"] or '!'
		for num, suf in pairs(records[pref] or {}) do
			local proc = true
			local num = tonumber(num) or 0
			if min then 
				if num < min then proc = false end
			end
			if max then 
				if num >  max then proc = false end
			end
			if stop then 
				if suf[stop] then proc = false end
			end
			if key then
				if not suf[key] then proc = false end
			end
			if proc then 
			  -- print(pref, num)
			  table.insert(t, selects[sel](suf))
			end
			-- zpracováváme signatury
		end
	end
	return t
end


-- řídící funkce
-- vstup je tabulka s poli:
--   input: získávání záznamů ze vstupního záznamu s pomocí select_records
--   template: výstupní šablona
local run_job = function(records, rules)
	local records = records or {}
	local start= {}
	local results= {}
	local template = rules.template
	local partials = rules.partials
	local cp = function(t) return t end
	local process = rules.process or {}
	local count = 0
	for rule, par in pairs(rules.input) do
		start[rule] = select_records(records, par)
		-- print("Processed rule", rule, "results", #start[rule])
	end
	for output, rules in pairs(process) do
		local fn = rules.process or function(a,b) table.insert(a,b); return a end
		local t = {}
		local loccnt = 0
		local input = rules.input or {}
		-- print("Output rules", output)
		for _, tbl in pairs(input) do
			-- print("Process table", tbl)
			local x = start[tbl] or {}
			for _, v in pairs(x) do
				t = fn(t, v)
				if t then 
					count = count + 1 
					loccnt = loccnt + 1
				end
			end
		end
		-- print "processed input"
		-- print_r(t)
		results[output] = t
		results[output]["localcount"] = loccnt
	end
	results["count"] = count
  return lustache:render(template, results, partials)
end

--[[
for k, v in pairs(zaznamy) do
	print(k, type(v))
end
--]]

local konspekt_tpl = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="stylesheet" type="text/css" href="nove.css" />
</head>
<body>
<h1>Přírustky dokumentů ({{count}})</h1>
{{#99}}
<h1>Záznamy bez konspektu</h2>
{{>zaznamy}}{{/99}}
<div class='konspekt' id='konspekt-1'>1. Antropologie, etnografie</div>
 {{#1}}{{>zaznamy}}{{/1}}

 <div class='konspekt' id='konspekt-2'>2. Biologické vědy</div>
 {{#2}}{{>zaznamy}}{{/2}}

 <div class='konspekt' id='konspekt-3'>3.  Divadlo, film, tanec</div>
 {{#3}}{{>zaznamy}}{{/3}}

 <div class='konspekt' id='konspekt-4'>4.  Ekonomické vědy, obchod</div>
 {{#4}}{{>zaznamy}}{{/4}}

 <div class='konspekt' id='konspekt-5'>5.  Filozofie a náboženství</div>
 {{#5}}{{>zaznamy}}{{/5}}

 <div class='konspekt' id='konspekt-6'>6.  Fyzika a příbuzné vědy</div>
 {{#6}}{{>zaznamy}}{{/6}}

 <div class='konspekt' id='konspekt-7'>7.  Geografie. Geologie. Vědy o zemi</div>
 {{#7}}{{>zaznamy}}{{/7}}

 <div class='konspekt' id='konspekt-8'>8.  Historie a pomocné historické vědy. Biografické studie</div>
 {{#8}}{{>zaznamy}}{{/8}}

 <div class='konspekt' id='konspekt-9'>9.  Hudba</div>
 {{#9}}{{>zaznamy}}{{/9}}

 <div class='konspekt' id='konspekt-10'>10.  Chemie. Krystalografie. Mineralogické vědy</div>
 {{#10}}{{>zaznamy}}{{/10}}

 <div class='konspekt' id='konspekt-11'>11.  Jazyk, lingvistika, literární věda</div>
 {{#11}}{{>zaznamy}}{{/11}}

 <div class='konspekt' id='konspekt-12'>12.  Knihovnictví, informatika, všeobecné, referenční literatura</div>
 {{#12}}{{>zaznamy}}{{/12}}

 <div class='konspekt' id='konspekt-13'>13.  Matematika</div>
 {{#13}}{{>zaznamy}}{{/13}}

 <div class='konspekt' id='konspekt-14'>14.  Lékařství</div>
 {{#14}}{{>zaznamy}}{{/14}}

 <div class='konspekt' id='konspekt-15'>15.  Politické vědy (Politologie, politika, veřejná správa, vojenství)</div>
 {{#15}}{{>zaznamy}}{{/15}}

 <div class='konspekt' id='konspekt-16'>16.  Právo</div>
 {{#16}}{{>zaznamy}}{{/16}}

 <div class='konspekt' id='konspekt-17'>17.  Psychologie</div>
 {{#17}}{{>zaznamy}}{{/17}}

 <div class='konspekt' id='konspekt-18'>18.  Sociologie</div>
 {{#18}}{{>zaznamy}}{{/18}}

 <div class='konspekt' id='konspekt-19'>19.  Technika, technologie, inženýrství</div>
 {{#19}}{{>zaznamy}}{{/19}}

 <div class='konspekt' id='konspekt-20'>20.  Tělesná výchova a sport. Rekreace</div>
 {{#20}}{{>zaznamy}}{{/20}}

 <div class='konspekt' id='konspekt-21'>21.  Umění, architektura, muzeologie</div>
 {{#21}}{{>zaznamy}}{{/21}}

 <div class='konspekt' id='konspekt-22'>22.  Výchova a vzdělávání</div>
 {{#22}}{{>zaznamy}}{{/22}}

 <div class='konspekt' id='konspekt-23'>23.  Výpočetní technika</div>
 {{#23}}{{>zaznamy}}{{/23}}

 <div class='konspekt' id='konspekt-24'>24.  Zemědělství</div>
 {{#24}}{{>zaznamy}}{{/24}}

 <div class='konspekt' id='konspekt-25'>25.  Beletrie</div>
 {{#25}}{{>zaznamy}}{{/25}}
 <!--
 Záznamy bez konspektu:
 {{#99}}{{>zaznamy}}{{/25}}
 -->
</body>
</html>
]]
--select_records(zaznamy, {

local nove_rule = {
	key="*",
	["select"]="*"
}
local rules = {
	input = {
		nove = {
			F = {
				key = "*",
				["select"] = "*"
			}, 
			U = {
				key="*",
				["select"]="*"
			},
			Sc = {
				key="*",
				["select"]="*"
			},
			Dt = nove_rule,
			["2Sc"] = nove_rule,
			Be = nove_rule
		}
	},
	process = {
		nove = {
			input = {"nove"},
			process = function(records, rec)
				local t = {}
				-- rozsekat políčka konspektu
				rec["z13u-user-defined-9"]:gsub("([0-9]+)", 
				  function(x) table.insert(t,x) end
				)
				if #t == 0 then
					table.insert(t,99)
				end
				-- označit název knihy odkazem do katalogu
				local ck = rec["z30-barcode"]
				-- 
				local odkaz1 = "http://ckis.cuni.cz/F/?func=find-e&request="
				local odkaz2= "&find_scan_code=FIND_IDN&adjacent=N&local_base=CKS&x=0&y=0&filter_code_1=WLN&filter_request_1=&filter_code_2=WYR&filter_request_2=&filter_code_3=WYR&filter_request_3=&filter_code_4=WFM&filter_request_4=&filter_code_5=WSL&filter_request_5=PEDFR"
				--rec["bib-info"] = rec["bib-info"]:gsub("^([^/]*)", function(x) 
				rec["bib-info"] = rec["bib-info"]:gsub("^(.*)/", function(x) 
					return "<a href='"..odkaz1..ck..odkaz2.."'>"..x.."</a>/"
				end):gsub("[%s]*%(#[^%)]*%)$","")
				local parse_author = function(a) 
					local a = a or ""
					local aut = a:match("([^,]+, [^%s]+)") or ""
					if aut:find "[0-9]+" then
						aut = aut:gsub("[a-zA-Z0-9]*[%s]*[aut]*[%s]*$","") 
					end
					return aut
				end
				rec["z13-author"] = parse_author(rec["z13-author"])
				rec["z13-isbn-issn"] = rec['z13-isbn-issn']:gsub("%s*%(.*$","")
				if rec["z13-isbn-issn"]:len() == 0 then
					rec["z13-isbn-issn"] = nil
				end
				-- projít všechny políčka konspektu, který záznam obsahuje 
				-- a přidat ho tam
				for _,v in pairs(t) do
					local c = records[v] or {}
					table.insert(c, rec)
					records[v] = c
				end
				return records 
			end
		}
	},
	template = 
[[{{#nove}}
{{> konspekt}}
{{/nove}}]],
  partials = {
	  konspekt = konspekt_tpl,
		zaznamy  = [[<div class='container'>
		<div class='cover'>
		  <img width='80px' height='80px' alt = '' src='http://www.obalkyknih.cz/api/cover?isbn={{z13-isbn-issn}}' />
		</div>
		<div class='record'>
		  <div class='author'>{{{z13-author}}}</div>
		  <div class='bib-info'>{{{bib-info}}}</div>
		{{#z13-isbn-issn}}
		  ISBN {{{z13-isbn-issn}}}
		{{/z13-isbn-issn}}
		</div>
		</div>
		]] 
	}
}
--[[-d,--dipl Diplomky
-r,--rekat Rekatalogizace
--]]
-- print "Spouštím job"
if args.dipl == true then
	local dipl_select = {
		Dp = nove_rule,
		Bp= nove_rule,
		Dis = nove_rule,
		Rig = nove_rule
	}
	rules.input.nove = dipl_select
elseif args.rekat == true then
end
print(run_job(zaznamy,rules))
--print "Konec jobu"
	--})