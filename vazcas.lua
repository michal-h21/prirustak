local pole =  {"z30-doc-number","z30-call-no","z13u-user-defined-1"} 
local parser= require "parse_prir"
local input = arg[1]
local f = parser.load_file(input)
local pos = parser.find_pos(f,pole)

parser.make_saves(pos)
local zaznamy= parser.parse(f)
local signatury = {}

local max = 1
for _, x in ipairs(zaznamy) do
	local sysno, signatura, nazev = x["z30-doc-number"],x["z30-call-no"],x["z13u-user-defined-1"]
  -- v seznamu jsou i jiný jednotky než časopisy, který obsahují `A` v sig.	
  local signo = tonumber(signatura:match("^A([0-9]+)"))
	local curr = signo or 0
  -- musíme najít nejvyšší signaturu, protože nemůžeme procházet tabulku 
  -- signatur s ipairs -- jsou tam díry
	max = curr > max and curr or max
	if signo then
    -- v každym čísle signatury může být víc podob signatury A1, A1a atd
		local s = signatury[signo] or {}
		local c = s[signatura] or {}
		-- co když je v signatuře víc sys. čísel?
		local j = c[sysno] or {}
		-- názvy taky můžou mít různou formu
		j[nazev] = true
		c[sysno] = j
		s[signatura] = c
		signatury[signo] = s
	end
end

for i = 1, max do
	local z = signatury[i]
	local x = {}
	if z then
		for signatura, sysnos in pairs(z) do
			for sysno, nazvy in pairs(sysnos) do
				for nazev, _ in pairs(nazvy) do
					local t = x[nazev] or {}
					t[#t+1] = {signatura=signatura,sysno=sysno}
					x[nazev] = t 
					--print(nazev, signatura, sysno )
				end
			end
		end
		for nazev, zaz in pairs(x) do
			local t = nil
			if #zaz > 1 then
				for _, c in ipairs(zaz) do
					if not c.signatura:match("[a-zAZ]$") then
						t = c
					end
				end
				if not t then t = zaz[1] end
			else
				t = zaz[1]
			end
			if t then
		    print(nazev, t.signatura, t.sysno)
			else
				print(zaznam, "co se děje?")
			end
		end
	else
		-- print( "neobsazená signatura","A"..i)
	end
end
