local csv = require "csv"

-- vytvořit soubory pro jednotlivé obory ve studovně
-- budou vytvořeny .tsv soubory ve složce katsig/new/
-- obor je druhá signatura bez čísla na konci
local f = csv.use(io.stdin, {})

local obory = {}
local title = {}
local first = true
for newfields in f:lines() do
  -- uložit jenom pole čk, rok, nazevautor a popis
  local fields = {newfields[1], newfields[3], newfields[7], newfields[11]}
  if first then 
    -- uložit hlavičku CSV souboru
    first = false
    title = table.concat(fields, "\t") .. "\n"
  else
    local sig2 = tostring(newfields[5])
    local obor = sig2:gsub("%s*[0-9]+$", ""):gsub("/", "-")
    if obor == "" then obor = "bezoboru" end
    local t = obory[obor] or {title}
    t[#t+1] = table.concat(fields, "\t") .."\n"
    obory[obor] = t
  end
end

for k,v in pairs(obory) do
  local f = io.open("katsig/new/".. k..".tsv", "w")
  for _, line in ipairs(v) do
    f:write(line)
  end
  f:close()
end
