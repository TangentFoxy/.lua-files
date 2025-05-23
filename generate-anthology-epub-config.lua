#!/usr/bin/env luajit

-- INPUT: File name containing a list of URLs to stories. If 1st line isn't a URL, it is the title to be used.
-- OUTPUT: A nearly complete config for use with make-epub.lua, named after the file name or title used.
-- Only works with LitErotica. Output JSON is minified, sorry.

local success, utility = pcall(function()
  return dofile((arg[0]:match("@?(.*/)") or arg[0]:match("@?(.*\\)")) .. "utility-functions.lua")
end)
if not success then
  print("\n\n" .. tostring(utility))
  error("\n\nThis script may be installed improperly. Follow instructions at:\n\thttps://github.com/TangentFoxy/.lua-files#installation\n")
end

local htmlparser = utility.require("htmlparser")
local json = utility.require("json")

local urls_file = arg[1]

-- silly default title, assumes .txt or other 3-digit extension, also clobbers some things
local title = utility.make_safe_file_name(urls_file:sub(1, -5))
if title:sub(1, 1) == "." then
  title = title:sub(2)
end

local config = {
  title = title,
  authors = {"Multiple Authors"},
  sections = {},
  section_titles = {},
  -- extract_titles = true, -- this script extracts them ahead of time, so don't duplicate that work
  automatic_naming = true,
  -- page_counts = {}, -- using discover_page_counts now!
  discover_page_counts = true,
}
local unique_authors = {} -- authors are stored in order of appearance, but a table of unique keys is kept to make sure duplicate entries aren't created

utility.open(urls_file, "r", "No such file " .. urls_file:enquote())(function(urls_file)
  local download_url = urls_file:read("*line")

  -- if first line isn't a url, it's the title!
  if download_url:sub(1, 4) ~= "http" then
    config.title = download_url
    download_url = urls_file:read("*line")
  end

  while download_url do
    if #download_url > 0 then
      local temporary_html_file_name = utility.tmp_file_name()
      os.execute("curl " .. download_url:enquote() .. " > " .. temporary_html_file_name)

      -- NOTE this is hardcoded for literotica

      utility.open(temporary_html_file_name, "r", "Could not download " .. download_url:enquote())(function(html_file)
        local raw_html = html_file:read("*all")
        local parser = htmlparser.parse(raw_html, 100000)

        local author = parser:select(".y_eS > .y_eU")[1]:getcontent()
        if not unique_authors[author] then -- only add them if they aren't already listed!
          config.authors[#config.authors + 1] =  author
          unique_authors[author] = true
        end
        config.sections[#config.sections + 1] = download_url
        config.section_titles[#config.section_titles + 1] = parser:select(".headline")[1]:getcontent():gsub("&#x27;", "'")
      end)
      os.execute("rm " .. temporary_html_file_name)

      os.execute("sleep " .. tostring(math.random(5))) -- avoid rate limiting
    end

    download_url = urls_file:read("*line")
  end
end)

-- correct author for single-author anthologies
if #config.authors == 2 then
  table.remove(config.authors, 1)
end

-- save "final" config
config.base_file_name = utility.make_safe_file_name(config.base_file_name or (config.title .. " by " .. config.authors[1]))
utility.open(config.base_file_name .. ".json", "w")(function(config_file)
  config_file:write(json.encode(config) .. "\n")
end)

-- print("! YOU MUST MANUALLY ADD THE CORRECT VALUES TO PAGE_COUNTS !")
