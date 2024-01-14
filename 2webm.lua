#!/usr/bin/env luajit

local helptext = [[Usage:

  2webm.lua [threads]

Converts everything in the local directory to webm, placed in "./2webm-output".

[threads]: Number of threads ffmpeg will be assigned.
           If a non-number value, 1 thread will be used.
]]

if arg[1] and arg[1]:find("help") then
  print(help)
  return false
end

local error_occurred, utility = pcall(function() return require("utility-functions") end) if not error_occurred then error("This script is installed improperly. Follow instructions at https://github.com/TangentFoxy/.lua-files#installation") end
utility.required_program("ffpmeg")

local threads = tonumber(arg[1]) or (arg[1] and 1)

local for_files = utility.ls()
os.execute("mkdir 2webm-output")

for_files(function(file_name)
  local command
  if threads then
    command = "ffmpeg -threads " .. threads .. " -i \"" .. file_name .. "\" -threads " .. threads .. " \"2webm-output/" .. file_name .. ".webm\""
  else
    command = "ffmpeg -i \"" .. file_name .. "\" \"2webm-output/" .. file_name .. ".webm\""
  end

  os.execute(command)
end)
