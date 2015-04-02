local pole =  {"z13-title","z30-item-status","z30-doc-number","z30-call-no","z13u-user-defined-1"} 
local parser= require "parse_prir"
local sort = require "sort"
local input = arg[1]
local f = parser.load_file(input)
local pos = parser.find_pos(f,pole)

parser.make_saves(pos)
local zaznamy= parser.parse(f)
local signatury = {}
local nazvy = {}
local t = {}

local max = 1
for _, x in ipairs(zaznamy) do
	local sysno, signatura, nazev, status , nazev= x["z30-doc-number"],x["z30-call-no"],x["z13u-user-defined-1"],x["z30-item-status"],x["z13-title"]
	nazev = nazev:gsub(" .$","")
	if status == "Prezenčně" then
		local current = nazvy[nazev] or {}
		local pocet = current.pocet or 0
		pocet = pocet + 1
		nazvy[nazev] = {pocet=pocet, signatura = signatura}
	end
end

for k, _ in  pairs(nazvy) do
	t[#t+1] = k
end

table.sort(t, sort.compare)
for _,v in ipairs(t) do
	local nazev = v
	local c = nazvy[nazev]
	local sig = c.signatura
	local pocet = c.pocet
	print(nazev, sig, pocet)
end
