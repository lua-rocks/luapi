--[[ Project Writer ]]--


local writer = require 'src.scriptum.writer'
local projWriter = {}


--[[ Write project index file
> rootPath (string)
> outPath (string)
> module (table)
]]
function projWriter.write(outPath, module)
  local file = writer.open(outPath.."/README.md")
  if not file then return end
  file:write("# Project Code Documentation\n\n## Index\n")
  for i = 1, #module.files do
    local name = module.reqs[i]
    local link = name..".md"
    file:write("\n+ ["..name.."]("..link..")\n")
  end
end


return projWriter
