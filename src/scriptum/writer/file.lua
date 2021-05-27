--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


--[[ Write title and module description ]]
local function writeH1()
end


--[[ Write table of contents ]]
local function writeTOC()
end


--[[ Write module contents]]
local function writeH2()
end


--[[ Write module links ]]
local function writeFooter()
end


--[[ Write file
> filePath (string)
> outPath (string)
> module (table)
]]
function fileWriter.write(filePath, outPath, module)
  local data = module.files[filePath]
  local file = writer.open(outPath .. '/' .. data.reqpath .. '.md')
  if not file then return end

  file:close()
end


return fileWriter
