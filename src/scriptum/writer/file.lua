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

  -- search for module table
  for tname, t in pairs(data.tables) do
    if t.order == 1 then
      data.name = tname
      output.text = '# ' .. t.title .. '\n\n' .. t.description .. '\n'
      break
    end
  end

  do -- separate internal and external tables and functions
    output.h2 = {
      int = {f = {}, t = {}},
      ext = {f = {}, t = {}}
    }
    for tname, t in pairs(data.tables) do
      t.name = tname
      if tname:find(data.name) == 1 then
        output.h2.int.t[t.order] = t
      else
        output.h2.ext.t[t.order] = t
      end
    end
    for fname, f in pairs(data.functions) do
      f.name = fname
      if fname:find(data.name) == 1 then
        output.h2.int.f[f.order] = f
      else
        output.h2.ext.f[f.order] = f
      end
    end
  end

  dump(output)

  file:write(output.text)
  file:close()
end


return fileWriter
