--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


--[[ First prep
> o (table) object
> r (table) return
> m (table) module
]]
local function prepareModule(o, r, m)
  o.fields = m.params
  o.header.text = '# ' .. m.title .. '\n\n' .. m.description .. '\n' ..
  '\n## Contents\n'
  o.body.text = '\n### ' .. o.classname .. '\n'
  o.footer.text = '\n[' .. o.classname .. ']: #' .. o.classname:lower() ..
  '\n\n[string]: https://www.lua.org/manual/5.1/manual.html#5.4\n' ..
  '[table]: https://www.lua.org/manual/5.1/manual.html#5.5\n'
  o.header:write('\n- _Fields_\n  - **[' .. o.classname .. '][]')
  if r.typing then
    o.header:write(' : [' .. r.typing .. '][]**')
    o.body:write('\nExtends: **[' .. r.typing .. '][]**\n')
    o.body:write('\nRequires: **none**\n')
  else
    o.header:write('**')
  end
  o.header:write('\n    - `No requirements`')
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
      output.modname = tname
      for classname, returns in pairs(t.returns) do -- luacheck: ignore
        output.classname = classname or tname
        prepareModule(output, returns, t)
        break
      end
      -- extract methods
      for fname, f in pairs(data.functions) do
        f.name = fname
        if fname:find(output.modname .. '%p') == 1 then
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
