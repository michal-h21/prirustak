#!/usr/bin/env texlua
local prir = require "parse_prir"

-- kompilace s $1 je xml soubor z alephu, $2 je rok ve formě,
-- v jaký je v přírustkovym seznamu. čili pro rok 2012 je to 212
--
local f = prir.load_file(arg[1])

local rada = tonumber("259" ..arg[2].. "0000")

prir.make_saves {20, 71, 73, 120, 65, 85, 121, 76}
local p = prir.parse(f)


local hlavicka = [[
\documentclass[twoside,  paper=landscape, fontsize=10]{scrartcl}
\areaset[2.5cm]{26cm}{19cm}
\usepackage{scrpage2}
\pagestyle{scrheadings}
\ofoot{}
\cfoot{\pagemark}
\ifoot{}
\recalctypearea
\footskip=4pt
\usepackage{longtable}
\usepackage[czech]{babel}
\usepackage{fontspec}
\usepackage{booktabs}
\setmainfont{TeX Gyre Heros}
\begin{document}
\newcommand\leftik[1]{{\raggedright #1}}
\parindent=0pt

\begin{longtable}{|p{6em}|p{6em}|p{19em}|p{5em}|p{6em}|p{6em}|p{4em}|p{5em}|p{5em}|}%
\hline

\noindent \bfseries \leftik{Přírůstkové\\číslo} &\bfseries Datum přír. č. 
&\bfseries Bibliografické údaje &\bfseries Signatura 
&\bfseries Objednávka &\bfseries \leftik{Dodavatel\\Faktura\\Datum}  
&\bfseries Cena &\bfseries \leftik{Interní\\ poznámka} 
&\bfseries \leftik{Poznámka pro OPAC}\\
\toprule
\endhead
\hline
]]

local paticka = [[
\end{longtable}
\end{document}
]]
print(hlavicka)

local escape = function(s)
	local s = s or ''
	if s:len() == 0 then return '-' end
	s = s:gsub('&amp;','&')
	s = s:gsub('&apos;',"'")
	s = s:gsub('/','\\slash ')
	local pattern = "[%#%&%%]"
	return s:gsub(pattern, function(x)
		return '\\'..x
	end)
end
local errors = {}

local kody = {}
for _, r in ipairs(p) do
	-- local bib, car, cena = escape(r['bib-info']), r['z30-barcode'], r['z30-price']
	local bib, car, cena = escape(r['z13u-user-defined-1']), tonumber(r['z30-barcode']) or 0, escape(r['z30-price'])

	local dif = tonumber(car) - rada
	if dif > 0 and dif < 10000 then
    last = last or car
    -- tohle nefunguje
		-- if car - last > 1 then
      -- -- vypsat všechny chybné kódy
      -- for i = car - last - 1, 1, -1 do
        -- errors[#errors+1] = car - i
        -- -- print("errr", car, i)
      -- end
		-- end
		last = car
    kody[#kody+1] = car
		if cena ~='-' then cena = cena .. ",- Kč" end
		local opac = escape(r['z30-note-opac']) 
		local internal = escape(r['z30-note-internal'])
		local order = escape(r['order-info'])
		local signatura = escape(r['z30-call-no'])
		local dodavatel = escape(r['z30-vendor-code'])
		local inv_date = escape(r['z30-inventory-number-date']):gsub("/",".")
		local invoice = escape (r['invoice-info'])
		dodavatel = dodavatel ..' '.. invoice
		print(string.format(
		'\\textbf{%s} & %s & %s & %s &\\leftik{%s} & %s & \\leftik{%s} & \\leftik{%s} & \\leftik{%s}\\\\ \\hline', 
		car, inv_date, bib, signatura, order, dodavatel, cena,internal, opac))
	end
end

--[[
for k,v in pairs(p[444]) do
print(k,v)
end
--]]
print(paticka)

print "Potenciální chyby"
table.sort(kody)
local last
for _, v in ipairs(kody) do
  last = last or v
  if v - last > 1 then
    for i = last + 1, v -1 do
      print(i)
    end
  end
  last = v
end
-- for _, x in ipairs(errors) do
-- 	print(x)
-- end
