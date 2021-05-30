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
  for path in pairs(module.files) do
    file:write("\n+ [" .. module.files[path].reqpath .. "](" ..
    path:gsub('%.lua$', '') .. ".md)\n")
  end
end


return projWriter
