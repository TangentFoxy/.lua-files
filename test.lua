#!/usr/bin/env luajit

-- if utility-functions.lua has an error, this won't show it, so for testing purposes, I don't use it here
-- local error_occurred, utility = pcall(function() return require("utility-functions") end) if not error_occurred then error("This script is installed improperly. Follow instructions at https://github.com/TangentFoxy/.lua-files#installation") end
utility = require("utility-functions")

print("---")

local threads = tonumber(arg[1]) or arg[1] or 1
print(threads, type(threads))

print("---")
