-- Potřebujeme udělat seznam všech jednotak signatury F od 1 do 4549

local parser= require "parse_prir"
local input = arg[1]
local f = parser.load_file(input)
local pos = parser.find_pos(f,{"is-loan", "z30-item-status","z30-call-no", "z30-barcode"})
parser.make_saves(pos)
local sort_table = {}
local records = {}
local zaznamy = parser.parse(f)
local sig_len = 6
for k, v in pairs(zaznamy) do
  --if v["is-loan"]== "Y" then
	local signatura = v["z30-call-no"]
  if signatura:match("^F") then
			-- zístak jen číselnou část signatury
			local s = signatura:match("F([0-9]+)")
			-- zarovnat podle jména
			local name = tonumber(s) --string.rep(" ", sig_len-string.len(s)) .. s
			-- přidat do tabulky na třídění
			if name < 4550 then
				sort_table[#sort_table + 1] = name
				-- přidat do tabulky signatur
				local x = records[name] or {}
				x[#x + 1] =  { 
					signatura = v["z30-call-no"], 
					status = v[ "z30-item-status"],
					carovy_kod = v["z30-barcode"]
				}
				records[name] = x
			end
		  --print(v["z30-call-no"],v[ "z30-item-status"])
		end
end

local used = {}
table.sort(sort_table)
for _, v in ipairs(sort_table) do
	if not used[v] then
		--print(v)
		local t = {}
		local k = {}
		for _,c in ipairs(records[v]) do 
			local s = c.signatura
			t[#t + 1] = s
			k[s] = {c.status, c.carovy_kod}
		end 
		table.sort(t)
		for _, c in ipairs(t) do
			print(c, k[c][1],k[c][2])
		end
	end
	used[v] = true
end
