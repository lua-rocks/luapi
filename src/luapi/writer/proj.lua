--[[ Project Writer ]]--
local projWriter = {}


local writer = require 'luapi.writer'


--[[ Write project index file
> outPath (string)
> module (table)
]]
function projWriter.write(outPath, module)
  local file = writer.open(outPath.."/README.md")
  if not file then return end
  file:write("# Project Code Documentation\n\n## Index\n\n")
  for path in pairs(module.files) do
    file:write("- [" .. module.files[path].reqpath .. "](" ..
    module.files[path].mdpath .. ")\n")
  end
end


return projWriter
