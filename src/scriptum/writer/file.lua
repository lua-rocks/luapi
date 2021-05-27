--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


--[[ Write file
> filePath (string)
> outPath (string)
> module (table)
]]
function fileWriter.write(filePath, outPath, module)
  local data = module.files[filePath]
  local file = writer.open(outPath .. '/' .. data.reqpath .. '.md')
  if not file then return end
  local output = {}

  for tname, t in pairs(data.tables) do
    if t.order == 1 then
      data.name = tname
      output.title = t.title
      output.description = t.description
    end
  end

  file:write('# ' .. output.title .. '\n\n' .. output.description .. '\n\n'
  )

  file:close()
end


return fileWriter
