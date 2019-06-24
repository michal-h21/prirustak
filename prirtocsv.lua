#!/usr/bin/env texlua -- konfigurovatelnej export alephovskýho xml do csv
-- arg[1] název 
-- arg[2] -- seznam polí oddělených čárkou (volitelný)
--

local input = arg[1]

local map = {
  ck = "z30-barcode",
  rok = "z13-year",
  druh = "z30-material",
  mail = "email-address",
  dilci = "z30-sub-library",
  sysno = "z30-doc-number",
  popis = "z30-description",
  status = "z30-item-status",
  ctenar = "z303-name",
  lokace = "z30-collection",
  pujceno = "is-loan",
  bibinfo = "bib-info",
  vypujcek = "z30-no-loans",
  signatura = "z30-call-no",
  id_ctenare = "z303-id",
  signatura2 = "z30-call-no-2",
  zpracovani = "z30-item-process-status",
  nazevautor = "z13u-user-defined-2",
  pujceno_do = "z36-due-date",
  prez_datum = "z309-date",
  podrobnosti = "z13u-user-defined-6",
  datum_vypujcky = "z36-loan-date",
  dilci_knihovna = "z30-sub-library",
  datum_narozeni = "z303-birth-date",
  status_ctenare = "z305-bor-status",
  datum_registrace = "z305-registration-date",
  konec_registrace = "z305-expiry-date",
  posledni_aktivita = "z305-last-activity-date",

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
      print("Chybí popisek pro pole: " .. name)
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
  local function print_header(format)
    local head = format:gsub(",", "\t")
    print(head)
  end
  print_header(format)
  -- získat pole, která budem tisknout ze záznamu
  local fields = parse_format(format)
  for _, row in ipairs(data) do
    local t = {}
    -- projít pole v záznamu a vytvořit tabulku, kterou budeme tisknout
    for _, f in ipairs(fields) do
      t[#t+1] = row[f] or ""
    end
    print(table.concat(t,"\t"))
  end
end



if not input then 
  print_help()
  os.exit()
end


local parser= require "parse_prir"
local source_format = arg[2] or "ck,sysno,rok,signatura,druh,nazevautor,lokace,status,dilci,popis"
local format = parse_format(source_format) 
local f = parser.load_file(input)
local pos = parser.find_pos(f,
format)
parser.make_saves(pos)

local zaz = parser.parse(f)
print_csv(source_format, zaz)
