local M = {}
kpse.set_program_name "luatex"

local entities = require "luaxml-entities"

local load_file = function(name)
	local f = io.open(name,"r")
	return f
end

local new_record = function(pos)
	return {}, 0 
end

local save_record = function(records, r)
	table.insert(records,r)
	return records
end

local pattern = '<(.-)>([^<]*)'
local saves = {[1]=true, [78]=true, [51]=true,}
local make_saves = function(t)
	for _,v in pairs(t) do
		saves[v] = true
	end
	return saves
end

-- Najít pozici polí v xml souboru
-- xml je vstupní soubor, t je pole s hledaný,ma tagama, root je section-2
local find_pos = function(xml, t, root)
	xml:seek('set')
	local root = root or 'section-02'
	local start_pattern = '<'..root..'>' 
	-- print(start_pattern)
	local end_pattern = "/"..root
	local pos = {}
	local rec = {}
	-- make hash table with searched elements from parameter t
	for _,v in pairs(t) do rec[v] = true end
	local start = false
	local i = 0
	for line in xml:lines() do
		if start then
			i = i + 1
			local match = line:match("<(.-)>")
			if match == end_pattern then
				make_saves(pos)
				return pos
			elseif rec[match] then 
				table.insert(pos,i)
			end
		else
			if line == start_pattern then 
				start = true
			end
		end
	end
	return pos
end

-- decode xml entites
local decode = entities.decode
local function escape(v)
  return decode(v)
end

local parse_line = function(r, l, pos)
  if r and saves[pos] then
		local k, v = l:match(pattern)
		r[k] = escape(v)
	end
	return r
end


local parse = function(f, root)
  local root = root or '<section-02>' 
	local position = 0
	local records = {}
	local r = nil
	f:seek('set')
	for line in f:lines() do
		position = position + 1
    print(position, ":" .. line .. ":")
		if line == root then
			records = save_record(records, r)
			r, position = new_record(position)
		else
			r = parse_line(r, line, position)
		end
	end
	records = save_record(records,r)
	return records
end


M.load_file = load_file
M.make_saves = make_saves
M.parse = parse
M.find_pos = find_pos
return M
