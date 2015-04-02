#!/usr/bin/env texlua
local input = arg[1]
local year =  arg[2]
local bodyfile = "text"..year..".html"
local konspekt = "nav".. year..".html"
local index = "index".. year .. ".html"
os.execute(string.format("texlua nove_knihy.lua %s %s > out/%s",input, year, bodyfile))
os.execute(string.format("texlua navigace.lua %s > out/%s", bodyfile, konspekt))
os.execute(string.format("texlua index.lua %s %s > out/%s",bodyfile ,konspekt , index))
