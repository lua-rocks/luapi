--[[ Project Writer ]]--
local projWriter = {}


local writer = require 'luapi.writer'


local output = {
  text = '',
  write = function(self, str)
    self.text = self.text .. str
  end
}


--[[ Write project index file
> outPath (string)
> module (table)
]]
function projWriter.write(outPath, module)
  local file = writer.open(outPath.."/README.md")
  if not file then return end
  output:write("# Project Code Documentation\n\n## Files\n\n")
  local sortedPaths = {}
  for path in pairs(module.files) do
    table.insert(sortedPaths, path)
  end
  table.sort(sortedPaths)
  for _, path in pairs(sortedPaths) do
    if module.files[path].module then
      output:write("- [" .. module.files[path].reqpath .. "](" ..
      module.files[path].mdpath .. ")\n")
    end
  end
  output:write("\n\n## Classes\n\n")
  for class, path in pairs(module.classes) do
    output:write("- [" .. class .. "](" ..
    module.files[path].mdpath .. ")\n")
  end
  file:write(output.text)
end


return projWriter
