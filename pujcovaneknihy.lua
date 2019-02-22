-- vybrat knížky do studovny podle půjčovanosti
local csv = require "csv"

local raw = io.read("*all")
local data = csv.openstring(raw, {header=true})

-- process only books released in this and following years
local start_year = 2012

local bibitems = {}

-- initialize bibliography record
local function initialize(rec)
  local new = {}
  -- just copy all fields
  for k,v in pairs(rec) do
    new[k] = v
  end
  -- number of holdings for the current bibitem
  new.count = 0
  -- how many times was the book borrowed?
  new.loans = 0
  -- initialize year
  new.rok = tonumber(new.rok)
  return new
end

-- test if the current book is in the study room
local function is_study_room(bibitem, rec)
  local current = rec.lokace == "Rett-studovna"
  return bibitem.studyroom or current
end

local function count_loans(bibitem, rec)
  return bibitem.loans + tonumber(rec.vypujcek)
end

local function handle_year(bibitem, rec)
  local year = tonumber(rec.rok)  or 0
  if year > 0 then return year end
  return bibitem.rok
end
-- expand some entities, discard unsupported
local entities =  {apos="'", lt="<", gt=">", amp="&", quot='"'}
local function expand_entities(text)
  return text:gsub("%&(.-);", function(a)
    return entities[a]
  end)
end

for rec in data:lines() do
  local sysno = rec.sysno
  local bibitem = bibitems[sysno] or initialize(rec)
  bibitem.studyroom = is_study_room(bibitem, rec)
  bibitem.count = bibitem.count + 1
  bibitem.loans = count_loans(bibitem, rec)
  bibitem.rok = handle_year(bibitem, rec)
  bibitems[sysno] = bibitem
  print(rec.ck, bibitem.studyroom,is_study_room(bibitem,rec), rec.lokace)
end


-- select new books to the study room
local to_study_room = {}
for sysno,bibitem in pairs(bibitems) do
  -- select only books 
  if not bibitem.studyroom and bibitem.rok >= start_year then
    -- print(sysno, bibitem.count, bibitem.loans, bibitem.loans / bibitem.count, bibitem.rok, bibitem.signatura,expand_entities( bibitem.nazevautor))
  end
end
