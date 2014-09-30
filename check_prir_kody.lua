local prir = require "parse_prir"

local f = prir.load_file(arg[1])
prir.make_saves {51}
local code = "z30-barcode"

print "Parsing"
local p =prir.parse(f)

local o = {}
local k = {}
print "Creating arrays"
for c,r in ipairs(p) do
	local f = r[code]
	table.insert(o, r[code])
	--table.insert(k, r[code])
	k[f] = c
end

print "Sorting array"
--table.sort(o)
print "Table sorted"
local last

--for i, x in ipairs(k) do
local start = 2592120001
for i = start, start+5800 do
	local x = k[tostring(i)]
	if not x then print(i,x) end
	--[[
	local num = x - 2592120000
	if num > 0 and num < 10000 then
		local c = tonumber(x)
		last = last or c
		local diff = c - last
		--if diff > 1 or diff < 0 then
			print(i, c, last, diff)
		--end
		last = c
	end
	--]]
end
print "Finish"
