#!/usr/bin/env texlua
local input = arg[1]
local year =  arg[2]
local bodyfile = "text_dp"..year..".html"
local konspekt = "nav_dp".. year..".html"
local index = "index_dp".. year .. ".html"
os.execute(string.format("texlua nove_knihy.lua -d %s %s > out/%s",input, year, bodyfile))
os.execute(string.format("texlua navigace.lua %s > out/%s", bodyfile, konspekt))
os.execute(string.format("texlua index.lua %s %s > out/%s",bodyfile ,konspekt , index))
