local sort = {}
local lower = unicode.utf8.lower
local normalize = function(s)
	return lower(s)
end

local gmatch = unicode.utf8.gmatch
local tokenize = function(s)
	local s = s or ""
	local t = {}
	for x in gmatch(s,"(.)") do
		-- print(x)
		t[#t+1]=x
	end
	return t
end

sort.sortstring = {}
sort.sortstring.czech = " .a.á.b.c.č.d.ď.e.é.ě.f.g.h.ch.i.í.j.k.l.m.n.ň.o.ó.p.q.r.ř.s.š.t.ť.u.ú.ů.v.w.x.y.ý.z.ž.0.1.2.3.4.5.6.7.8.9.:.-"

local sorttable = {}
local len = unicode.utf8.len
sort.language = function(lang)
	local sortstring = sort.sortstring[lang]
	local maxlen = 0
	local max = 0
	for k,v in ipairs(sortstring:explode(".")) do
		local l = len(v)
		maxlen = maxlen < l and l or maxlen
		sorttable[v] = k
		max = k
	end
	sorttable["maxlen"] = maxlen
	sorttable["maxval"] = max + 1
end


local function find_match(t, pos, len)
	if len < 1 then
		return sorttable["maxval"], pos + 1
	end
	local ch = {}
	for i= pos, pos+len-1 do
		ch[#ch+1] = t[i]
	end
	local char = table.concat(ch)
  --	print("char",char)
	local val = sorttable[char] 
	if not val then return find_match(t, pos, len-1) end
	return val, pos + len 
end

-- print("maxlen",maxlen)


sort.language("czech")
-- local t =  tokenize(normalize("chkČšžCŤ"))
-- for _,x in ipairs(t) do
-- 	print(x, sorttable[x])
-- end

local function make_comp_table(t) 
	local pos = 1
	local max = sorttable["maxlen"]
	local i = {}
	while pos < #t do
		val, pos = find_match(t, pos,max)
		i[#i+1] = val
	end
	return i
end

-- for _,v in ipairs(make_comp_table(t)) do
-- 	print(v)
-- end

local function prepare(s)
	return make_comp_table(tokenize(normalize(s)))
end

local function compare(t1,t2,pos)
	local t1 = t1 
	local t2 = t2
	if type(t1) == "string" then 
		t1 =  prepare(t1) 
	end
	if type(t2) == "string" then 
		t2 =  prepare(t2) 
	end
	local pos = pos or 1
	if pos > #t1 and pos> #t2 then return 0>1  end
	-- musíme použít velký číslo
	-- když jsme použil 0, dostal jsme chybu
	local x1 = t1[pos] or 0
	-- if not x1 then return 0>1 end
	local x2 = t2[pos] or 0
	-- if not x2 then return 0<1 end
	if x1 == x2 then
		return compare(t1,t2,pos+1)
	end
	return x1 < x2 
end


-- print(compare(prepare("caha"),prepare("cacha")))
-- local t =  {"ahoj","cosi","čau","ddd","holub","chochol","jaaa","bbbb", "xx","xxx", "x xx","xxx", "","", "xxx"}
-- 
-- table.sort(t, function(a,b)
-- 	-- return compare(prepare(a),prepare(b))
-- 	return compare(a,b)
-- end)
-- 
-- for _, v in ipairs(t) do
-- 	print(v)
-- end
 
sort.compare = compare
sort.prepare = prepare
return sort
