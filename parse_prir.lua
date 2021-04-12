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
  local root = root or 'section-02' 
  root = "<" .. root .. ">"
	local position = 0
	local records = {}
	local r = nil
	f:seek('set')
	for line in f:lines() do
		position = position + 1
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
  konspekt = "z13u-user-defined-9",
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
  druh_studia = "z305-field-1",
  druh_studia2 = "z305-field-2",
  datum_odpisu = "z30-item-statistic",
  katalogizator = "z30-cataloger",
  pujceno_datum = "z36-loan-date",
  vraceno_datum = "z36-returned-date",
  poznamka_opac = "z30-note-opac",
  datum_vypujcky = "z36-loan-date",
  dilci_knihovna = "z30-sub-library",
  datum_narozeni = "z303-birth-date",
  status_ctenare = "z305-bor-status",
  pujceno_stanice = "z36-loan-cataloger-ip",
  posledni_vraceni = "z30-date-last-return",
  datum_zpracovani = "z30-inventory-number-date",
  interni_poznamka = "z30-note-internal",
  posledni_vraceni = "z30-date-last-return",
  poznamka_pujceni = "z30-note-circulation",
  datum_registrace = "z305-registration-date",
  konec_registrace = "z305-expiry-date",
  posledni_aktivita = "z305-last-activity-date",

}--,"z13u-user-defined-10","z13u-user-defined-3"}

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
    -- a smaz vsechny uvozovky -- delaji problem pri nahravani v LO Calc
    return s:match("^([^%/]+)"):gsub("'", ""):gsub('"', "") or ""
  end,
  isbn = function(s)
    -- pro jistotu smaz mezery na zacatku, kdyby se nahodou vyskytovaly
    local s = s:gsub("^%s*", "")
    -- vrat vsechno po prvni mezeru
    return s:match("^([^%s]+)") or ""
  end

}

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

-- cleanup polí, které to potřebují
local function edit(fieldname, value)
  -- zjistit, jestli existuje čistící funkce pro zpracovávané pole
  local fn = edits[fieldname] or function(val) return val end
  return fn(value)
end
    
-- format obsahuje názvy polí z xml souboru
-- name_fields nazvy poli predany z CLI
local function print_csv(format, data, source_format)
  -- ziskat nazvy poli
  local name_fields = parse_format_string(format)
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
    local line = table.concat(t,"\t")
    -- nahradit znaky ", delaji problem pri otevreni v Calcu
    line = line:gsub('"', "'")
    print(line)
  end
end



M.load_file = load_file
M.make_saves = make_saves
M.parse = parse
M.find_pos = find_pos
M.field_map = map
M.print_csv = print_csv
M.parse_format = parse_format
M.parse_format_string = parse_format_string
M.edit = edit
return M
