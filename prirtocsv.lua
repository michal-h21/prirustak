#!/usr/bin/env texlua 
-- konfigurovatelnej export alephovskýho xml do csv
-- arg[1] název 
-- arg[2] -- seznam polí oddělených čárkou (volitelný)
--

local input = arg[1]

local map = {
  ck = "z30-barcode",
  rok = "z13-year",
  cena = "z30-price",
  druh = "z30-material",
  isbn = "z13-isbn-issn",
  mail = "email-address",
  dilci = "z30-sub-library",
  sysno = "z30-doc-number",
  autor = "z13-author",
  mesto = "z13-imprint",
  popis = "z30-description",
  status = "z30-item-status",
  ctenar = "z303-name",
  nazev = "z13u-user-defined-2",
  lokace = "z30-collection",
  pujceno = "is-loan",
  bibinfo = "bib-info",
  faktura = "z30-invoice-number",
  rozpocet = "order-info",
  vypujcek = "z30-no-loans",
  signatura = "z30-call-no",
  dodavatel = "z30-vendor-code",
  vydavatel = "z13u-user-defined-5",
  id_ctenare = "z303-id",
  signatura2 = "z30-call-no-2",
  zpracovani = "z30-item-process-status",
  nazevautor = "z13u-user-defined-2",
  pujceno_do = "z36-due-date",
  prez_datum = "z309-date",
  podrobnosti = "z13u-user-defined-6",
  pujceno_cas = "z36-loan-hour",
  vraceno_cas = "z36-returned-hour",
  pujceno_datum = "z36-loan-date",
  vraceno_datum = "z36-returned-date",
  datum_vypujcky = "z36-loan-date",
  dilci_knihovna = "z30-sub-library",
  datum_narozeni = "z303-birth-date",
  status_ctenare = "z305-bor-status",
  pujceno_stanice = "z36-loan-cataloger-ip",
  datum_zpracovani = "z30-inventory-number-date",
  interni_poznamka = "z30-note-internal",
  posledni_vraceni = "z30-date-last-return",
  poznamka_pujceni = "z30-note-circulation",
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

local function parse_format_string(s)
  local names = {}
  for name in s:gmatch "%s*([^%,]+)" do
    names[#names+1] = name
  end
  return names
end

local function parse_format(s)
  local fields = {}
  local names = parse_format_string(s)
  -- for name in s:gmatch "%s*([^%,]+)" do
  for _, name in ipairs(names) do
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

local edits = {
  autor = function(s)
    -- odstranit autoritni udaje
    local autor = s:gsub("[a-zA-Z]+[0-9]+ ???$", "")
    -- autor ve formatu Prijmeni, Jmeno
    if s:match("^[^%s]+%s?[^%s]*, ") then
      -- odstranit rok narozeni
      autor = autor:gsub("[0-9].+$", "")
      -- odstranit carku a mezery na konci
      autor = autor:gsub(",?%s*$", "")
    else
      -- korporatni nazev
    end
    -- porad tu muzou byt nadbytecne znaky
    -- nevyhoda je, ze to muze smazat "von" a podobne. ale porad lepsi nez cistit hromadu balastu
    return autor:gsub(" [a-z]?[a-z]?[a-z]$","")
  end,
  vydavatel = function(s)
    -- nadbytecna carka
    return s:gsub(",%s*$","") 
  end,
  nazev = function(s)
    -- vrat vsechno po lomitko
    -- a smaz vsechny uvozovky
    return s:match("^([^%/]+)"):gsub("'", ""):gsub('"', "") or ""
  end,
  isbn = function(s)
    -- pro jistotu smaz mezery na zacatku, kdyby se nahodou vyskytovaly
    local s = s:gsub("^%s*", "")
    -- vrat vsechno po prvni mezeru
    return s:match("^([^%s]+)") or ""
  end

}

-- cleanup polí, které to potřebují
local function edit(fieldname, value)
  -- zjistit, jestli existuje čistící funkce pro zpracovávané pole
  local fn = edits[fieldname] or function(val) return val end
  return fn(value)
end
    
-- format obsahuje názvy polí z xml souboru
-- name_fields nazvy poli predany z CLI
local function print_csv(format, data, format_string)
  -- ziskat nazvy poli
  local name_fields = parse_format_string(format_string)
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
    for i, f in ipairs(fields) do
      t[#t+1] = edit(name_fields[i], row[f] or "")
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
print_csv(source_format, zaz,source_format)
