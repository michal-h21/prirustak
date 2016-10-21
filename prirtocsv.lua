-- konfigurovatelnej export alephovskýho xml do csv
-- arg[1] název 
-- arg[2] -- seznam polí oddělených čárkou (volitelný)
--

local input = arg[1]

local map = {
  pujceno = "is-loan",
  status = "z30-item-status",
  signatura = "z30-call-no",
  ck = "z30-barcode",
  bibinfo = "bib-info",
  rok = "z13-year",
  dilci = "z30-sub-library",
  lokace = "z30-collection",
  sysno = "z13u-doc-number"
}--,"z13u-user-defined-10","z13u-user-defined-3"}

local function print_help()
  print "prirtocsv prirsobor 'format'"
  print "Dostupné pole pro formát:"
  for k,v in pairs(map) do
    print(k,v)
  end
end

local function parse_format(s)
  local fields = {}
  for name in s:gmatch "%s*([^%,]+)" do
    local field = map[name]
    if not field then
      print_help()
      os.exit()
    end
    fields[#fields+1] = field
  end
  return fields
end
    
-- format obsahuje názvy polí
local function print_csv(format, data)
  -- vytisknout hlavičku
  print(format)
  -- získat pole, která budem tisknout ze záznamu
  local fields = parse_format(format)
  for _, row in ipairs(data) do
    local t = {}
    -- projít pole v záznamu a vytvořit tabulku, kterou budeme tisknout
    for _, f in ipairs(fields) do
      t[#t+1] = row[f]
    end
    print(table.concat(t,"\t"))
  end
end



if not input then 
  print_help()
  os.exit()
end

local parser= require "parse_prir"
local source_format = arg[2] or "ck,sysno,signatura,bibinfo,lokace,status,dilci"
local format = parse_format(source_format) 
local f = parser.load_file(input)
local pos = parser.find_pos(f,
format)
parser.make_saves(pos)

local zaz = parser.parse(f)
print_csv(source_format, zaz)
