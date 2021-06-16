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
  local file = writer.open(outPath .. '/README.md')
  if not file then return end
  output:write('# Project Code Documentation\n\n## Files\n\n')
  local sortedPaths = {}
  for path in pairs(module.files) do
    table.insert(sortedPaths, path)
  end
  table.sort(sortedPaths)
  for _, path in pairs(sortedPaths) do
    local iFile = module.files[path]
    if iFile.module then
      local classname
      if iFile.module.returns then
        classname = ' (' .. iFile.module.returns.name .. ')'
      end
      output:write('- [' .. iFile.reqpath .. (classname or '') ..
      '](' .. iFile.mdpath .. ')\n')
    end
  end
  file:write(output.text)
end


return projWriter
