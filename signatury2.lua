-- Potřebujeme udělat seznam všech jednotak signatury F od 1 do 4549

local parser= require "parse_prir"
local input = arg[1]
local f = parser.load_file(input)
local match = arg[2] or ""
local pos = parser.find_pos(f,
      {"z30-item-status","z30-call-no", "z30-barcode", "z30-collection", 
      "z30-call-no-2","z13-year","z13-author","z13-title","z13u-user-defined-5"
      ,"z13u-user-defined-1","z13u-user-defined-2","z13u-user-defined-3"
    })

local print_rec = function(x)
  local i = {}
  for _, j in ipairs({"z13-title","z13-author","z13-year","z30-call-no","z30-call-no",
 "z30-barcode",      "z30-call-no-2"}) do
    i[#i+1] = x[j]
  end
  i[1] = i[1]:gsub("[%s]*/[%s]*$","")
  if i[1] == "" then
    i[1] = x["z13u-user-defined-1"]:match("([^/]*)%s*/")
    if not i[1] then
      i[1] = x["z13u-user-defined-2"]:match("([^%/]*)%s*") or ""
    end
  end
  if not i[2] or i[2] == "" then
    i[2] = x["z13u-user-defined-1"]:match("/ ([^%-]-)") or ""
  end
  -- i[2] = i[2]:match("([^%,]*, [^%s]*)")  or "" 
  i[2] = i[2]:gsub("[0-9].*","")
-- <z13u-user-defined-3>##Postupný nácvik trapasů, aneb, Jak překonat sociální fobii : svépomocná příručka / Ján Praško, Beata Pašková, Hana Prašková, Dagmar Seifertová##1. vyd.##Praha : Psychiatrické centrum Praha, 1998##139 s. : tab., obr.</z13u-user-defined-3>
  local t = {}
  x["z13u-user-defined-3"]:gsub("%#%#([^%#]*)", function(a)
    t[#t+1] = a
  end)
  local nakladatel, strany = t[#t-1],t[#t]
  local vydavatel, rok =nakladatel:match( ".*: (.*), (.*)")
  vydavatel = vydavatel or ""
  strany = strany:match("(.- s.)") or strany:match("([^%:]*)")
  -- table.insert(i, rok)
  i[3] = rok or "bez data"
  table.insert(i,4, vydavatel)
  --table.insert(i, 4, strany)
  i[5] = strany
  -- print(table.concat(t,"\t"))
  -- print(vydavatel,rok)
  --[[if not i[2] then 
    print "hhhhh"
    print(x["z13u-user-defined-2"])
    local f, l = x["z13u-user-defined-2"]:match("/ (.-) (.-) ")
    if f and l then
      i[2] = l ..", " ..f
    else
      i[2] = ""
    end
  end --]]
  print(table.concat(i,"\t"))
end
parser.make_saves(pos)
local sort =  require "sort"
local sort_table = {}
local records = {}
local zaznamy = parser.parse(f)
local sig_len = 6


for k, v in pairs(zaznamy) do
  --if v["is-loan"]== "Y" then
	local signatura2 = v["z30-call-no-2"]
  local rec = records[signatura2] or {}
  rec[#rec+1] = v
  records[signatura2] = rec
end

for x,y in pairs(records) do
  --print(x,#y)
  if x:match(match) then
    table.sort(y,function(a,b)
      local a1 = a["z13-author"]
      local a2 = b["z13-author"]
      return sort.compare(a1,a2)
    end)
    for _,x in ipairs(y) do
      print_rec(x)
    end
  end
end

