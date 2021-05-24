--[[ Project Writer ]]--
local projWriter = {}


local writer = require 'scriptum.writer'


--[[ Write project index file
> outPath (string)
> module (table)
]]
function projWriter.write(outPath, module)
  local file = writer.open(outPath.."/README.md")
  if not file then return end
  file:write("# Project Code Documentation\n\n## Index\n")
  for i = 1, #module.files do
    local name = module.requires[i]
    local link = name..".md"
    file:write("\n+ ["..name.."]("..link..")\n")
  end
end


return projWriter
