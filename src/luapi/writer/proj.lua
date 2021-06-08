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
  file:write("# Project Code Documentation\n\n## Files\n\n")
  local sortedPaths = {}
  for path in pairs(module.files) do
    table.insert(sortedPaths, path)
  end
  table.sort(sortedPaths)
  for _, path in pairs(sortedPaths) do
    if module.files[path].module then
      file:write("- [" .. module.files[path].reqpath .. "](" ..
      module.files[path].mdpath .. ")\n")
    end
  end
end


return projWriter
