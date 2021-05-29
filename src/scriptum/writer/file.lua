--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


local function prepareModule(output, classname, returns, t)
  output.fields = t.params
  output.header.text = '# ' .. t.title .. '\n\n' .. t.description .. '\n' ..
  '\n## Contents\n'
  output.header:write('\n- _Fields_\n  - **[' .. classname .. '][] : [' ..
  returns.typing .. '][]**\n    - `No requirements`')
  output.body.text = '\n### ' .. classname .. '\n'
  output.footer.text = '\n[' .. classname .. ']: #' .. classname:lower() ..
  '\n\n[string]: https://www.lua.org/manual/5.1/manual.html#5.4\n' ..
  '[table]: https://www.lua.org/manual/5.1/manual.html#5.5\n'
end


local function prepareField(output, field)
end


local function prepareMethod(output, method)
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
    body = { write = write },
    footer = { write = write },
  }

  -- search for module table and handle it
  for tname, t in pairs(data.tables) do
    if t.order == 1 then
      data.name = tname
      for classname, returns in pairs(t.returns) do -- luacheck: ignore
        data.classname = classname or data.name
        prepareModule(output, classname, returns, t)
        break
      end
      -- extract methods
      for fname, f in pairs(data.functions) do
        f.name = fname
        if fname:find(data.name .. '%p') == 1 then
          output.methods[f.order] = f
        end
      end
      -- prepare output
      for _, field in pairs(output.fields) do
        prepareField(output, field)
      end
      output.header:write('\n- _Methods_\n')
      for _, method in pairs(output.methods) do
        prepareMethod(output, method)
      end
      break
    end
  end

  file:write(output.header.text .. output.body.text .. output.footer.text)
  file:close()
  --dump(output)
end


return fileWriter
