local input = arg[1]


local function parse_authors(bibinfo)
  local name, author, supervizor = bibinfo:match("(.-)%s*/%s*(.-)%s*[;%:](.+)")
  if not name then 
    name, author = bibinfo:match("(.-)%s*/%s*(.-)")
  end
  if supervizor then 
    supervizor = supervizor:gsub("ved.-práce", ""):gsub("supervisor",""):gsub("vedoucí DP", ""):gsub(".-konzultace", "")
  end
  name = name:gsub("%s*%[rukopis%]%s*","")
  return name, author, supervizor
end


-- katedra může bejt ve dvou polích
local function parse_katedra(a, b)
  local katedra 
  -- buď v předmětových heslech
  for field in a:gmatch("([^%*]+)") do
    if field:match("[kK]atedra") then 
      katedra = field:gsub("^.-:%s*","")
    end
  end
  -- nebo ve vydavatelských údajích
  if not katedra then 
    katedra = b:match("(Katedra.+)%, [0-9]+$")
  end
  return katedra
end

local parser= require "parse_prir"
local format = {"z13u-user-defined-2", "z30-item-status","z30-call-no", "z30-barcode","z13-year","z13u-user-defined-10","z13u-user-defined-11","z30-doc-number"}
local f = parser.load_file(input)
local pos = parser.find_pos(f,
format)
parser.make_saves(pos)

local zaz = parser.parse(f)

for k,v in ipairs(zaz) do
  local name, author, supervizor = parse_authors(v["z13u-user-defined-2"])
  local katedra = parse_katedra(v["z13u-user-defined-10"],v["z13u-user-defined-11"])
  local record = {v["z30-doc-number"],author, name, supervizor or "", katedra or "", v["z30-barcode"], v["z30-call-no"]}
  print(table.concat(record, "\t"))
end
