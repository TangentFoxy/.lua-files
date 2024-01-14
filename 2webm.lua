#!/usr/bin/env luajit

local help = [[Usage:

  2webm.lua [threads=1]

Converts everything in the local directory to webm, placed in "./2webm-output".
(Defaults to using only a single thread to reduce impact on the system.)

[threads]: Number of threads ffmpeg will be assigned.
           If a non-number value, ffmpeg's -threads flag will not be used.
]]

if arg[1] and arg[1]:find("help") then
  print(help)
  return false
end

local error_occurred, utility = pcall(function() return dofile(arg[0]:match("@?(.*/)") or arg[0]:match("@?(.*\\)") .. "utility-functions.lua") end) if not error_occurred then error("\n\nThis script is installed improperly. Follow instructions at:\n\thttps://github.com/TangentFoxy/.lua-files#installation\n") end
utility.required_program("ffmpeg")

local threads = tonumber(arg[1]) or arg[1] or 1

local for_files = utility.ls()
os.execute("mkdir 2webm-output")

for_files(function(file_name)
  local command
  if type(threads) == "number" then
    command = "ffmpeg -threads " .. threads .. " -i \"" .. file_name .. "\" -threads " .. threads .. " \"2webm-output/" .. file_name .. ".webm\""
  else
    command = "ffmpeg -i \"" .. file_name .. "\" \"2webm-output/" .. file_name .. ".webm\""
  end

  os.execute(command)
end)
