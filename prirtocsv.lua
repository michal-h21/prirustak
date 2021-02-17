#!/usr/bin/env texlua 
-- konfigurovatelnej export alephovskýho xml do csv
-- arg[1] název 
-- arg[2] -- seznam polí oddělených čárkou (volitelný)
--

local input = arg[1]

local parser= require "parse_prir"

local map = parser.field_map

local function print_help()
  print "prirtocsv prirsobor 'format'"
  print "Dostupné pole pro formát:"
  for k,v in pairs(map) do
    print(k,v)
  end
end


if not input then 
  print_help()
  os.exit()
end



local source_format = arg[2] or "ck,sysno,rok,signatura,druh,nazev,autor,vydavatel,lokace,status,dilci,popis"
local format = parser.parse_format(source_format) 
local f = parser.load_file(input)
local pos = parser.find_pos(f,
format)
parser.make_saves(pos)

local zaz = parser.parse(f)
parser.print_csv(source_format, zaz)
