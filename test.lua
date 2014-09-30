#!/usr/bin/env texlua
-- arg 1 xml soubor z alephu
-- arg 2 zpracovávaný měsíc ve tvaru měsíc-rok
local prir = require "parse_prir"
local f = prir.load_file(arg[1])
local code = "z30-barcode"
local inv_date = "z30-inventory-number-date"
local bib = "z13u-user-defined-2"
local nakl = "z13-imprint"
local isbn = "z13-isbn-issn"
local k = prir.find_pos(f,{code, inv_date, bib, nakl, isbn})
local j = prir.parse(f)

for _,rec in pairs(j) do
	for k,v in pairs(rec) do
		print(k,v)
	end
	print("-------")
end
