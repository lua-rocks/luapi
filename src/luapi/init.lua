--[[ LUAPI (WIP)
This document was created with this luapi. View the lua source file to see
example input and see the raw markdown file for example output.

> files ({string=table...}) require path = parsed file table
> paths (list) project paths
< luapi (table)
]]
local luapi = {}


--[[
> rootPath (string) path to read source code from
> outPath (string) ["doc"] path to output to (relative to root)
> pathFilters (list) [] search files only in these subdirs (relative to root)
]]
luapi.config = {
  outPath = "doc",
}


local projParser = require 'parser.proj'
local fileParser = require 'parser.file'
local projWriter = require 'writer.proj'
local fileWriter = require 'writer.file'


--[[ Start document generation
> config (luapi.config)
]]
function luapi.start(config)
  for k, v in pairs(config) do luapi.config[k] = v end

  local rootPath = luapi.config.rootPath
  local pathFilters = luapi.config.pathFilters
  local outPath = luapi.config.outPath

  luapi.files = {}

  -- Parse --
  local files, requires = projParser.getFiles(rootPath, pathFilters)
  for index, reqpath in ipairs(requires) do
    luapi.files[reqpath] = fileParser.parse(files[index])
    luapi.files[reqpath].luapath = files[index]
    luapi.files[reqpath].mdpath = rootPath .. '/' .. outPath .. '/' ..
      requires[index] .. '.md'
  end

  -- Generate markdown --
  projWriter.write(outPath, luapi)
  for reqpath in pairs(luapi.files) do
    fileWriter.write(reqpath, luapi)
  end
end


return luapi
