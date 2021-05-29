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

  do -- separate external/internal tables/functions
    output.h2 = {
      {}, {}, {}, {},
      'Fields', 'Methods', 'Tables', 'Functions'
    }
    for tname, t in pairs(data.tables) do
      t.name = tname
      if t.order == 1 then
        output.h2[1][t.order] = t
      else
        if tname:find(data.name .. '%p') == 1 then
          output.h2[1][t.order] = t
        else
          output.h2[3][t.order] = t
        end
      end
    end
    for fname, f in pairs(data.functions) do
      f.name = fname
      if fname:find(data.name .. '%p') == 1 then
        output.h2[2][f.order] = f
      else
        output.h2[4][f.order] = f
      end
    end
  end

  for h2index = 1, 4 do
    if table.maxn(output.h2[h2index]) == 0 then goto next end
    output.text = output.text .. '\n## ' .. output.h2[h2index+4] .. '\n'
    for _, element in pairs(output.h2[h2index]) do
      output.text = output.text .. '\n### ' .. element.name .. '\n'
    end
    ::next::
  end

  file:write(output.text)
  file:close()
end


return fileWriter
