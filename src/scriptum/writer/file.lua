--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


local function prepareField(out, field)

end


local function prepareMethod(out, method)

end


--[[ Write file
> filePath (string)
> outPath (string)
> module (table)
]]
function fileWriter.write(filePath, outPath, module)
  local data = module.files[filePath]
  local file = writer.open(outPath .. '/' .. data.reqpath .. '.md')
  if not file then return end
  local write = function(self, text) self.text = self.text .. text end
  local output = {
    methods = {},
    header = { write = write },
    body = { write = write, text = '' },
  }

  -- search for module table
  for tname, t in pairs(data.tables) do
    if t.order == 1 then
      data.name = tname
      for classname in pairs(t.returns) do -- luacheck: ignore
        data.classname = classname or tname
        break
      end

      output.header.text = '# ' .. t.title .. '\n\n' .. t.description .. '\n' ..
      '\n## Contents\n'
      output.body.text = '\n### ' .. data.classname .. '\n'
      output.fields = t.params
      break
    end
  end

  -- extract methods
  for fname, f in pairs(data.functions) do
    f.name = fname
    if fname:find(data.name .. '%p') == 1 then
      output.methods[f.order] = f
    end
  end

  -- prepare output
  output.header:write('\n- _Fields_\n')
  for _, field in pairs(output.fields) do
    prepareMethod(output, field)
  end
  output.header:write('\n- _Methods_\n')
  for _, method in pairs(output.methods) do
    prepareMethod(output, method)
  end

  --[[
  output:write('\n## ' .. output[h2index+2] .. '\n')
  for element_index, element in pairs(output[h2index]) do
    output:write('\n### ' .. element.name .. '\n')
    if element_index == 1 then
      output:write '\n- type: **[this module][]**\n- requirements: **none**\n'
      for param_name, param in pairs(element.params) do
        if param.description then
          output:write('\n### ' .. element.name .. '.' .. param_name ..
          '\n\n> ' .. param.description:gsub('\n', '\n> ') .. '\n\n')
        end
        if param.typing then
          output:write('- type: **' .. param.typing .. '**\n')
        end
        if param.default == '' then
          output:write('- _optional_\n')
        else
          output:write('- default: `' .. param.default .. '`\n')
        end
      end
      goto next
    end
    if element.title then
      output:write('\n' .. element.title .. '\n')
    end
    if element.description then
      output:write('\n> ' .. element.description:gsub('\n', '\n> ') .. '\n')
    end
    if h2index == 1 or h2index == 3 then -- tables
    else -- functions
    end
    ::next::
  end
  ]]--

  file:write(output.header.text .. output.body.text)
  file:close()
  --dump(output)
end


return fileWriter
