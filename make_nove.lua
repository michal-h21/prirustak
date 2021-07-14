#!/usr/bin/env texlua
local input = arg[1]
local year =  arg[2]
if not year then
  print("Usage: make_nove.lua xml date")
  print("Correct date form: MM-YYYY")
  os.exit()
end
if not year:match("..%-....") then
  print("Wrong date format: " .. year)
  print("Correct form: MM-YYYY")
  os.exit()
end
local bodyfile = "text"..year..".html"
local konspekt = "nav".. year..".html"
local index = "index".. year .. ".html"
os.execute(string.format("texlua nove_knihy.lua %s %s > out/%s",input, year, bodyfile))
os.execute(string.format("texlua navigace.lua %s > out/%s", bodyfile, konspekt))
os.execute(string.format("texlua index.lua %s %s > out/%s",bodyfile ,konspekt , index))

-- copy files to web
local function copy(...)
  local arg = {...}
  for _, name in ipairs(arg) do
    print("copy " .. name)
    os.execute(string.format("cp out/%s ../pedf-web-navrh/backup/nove_knihy/", name))
  end
end

copy(bodyfile, konspekt, index)
