--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'scriptum.writer'


--[[ First prep
> o (table) object
> r (table) return
> m (table) module
]]
local function prepareModule(o, r, m, module)
  o.fields = m.params
  o.header.text = '# ' .. m.title .. '\n\n' .. m.description .. '\n' ..
  '\n## Contents\n'
  o.body.text = '\n### ' .. o.classname .. '\n'
  o.footer.text = '\n## Footer\n\n[Back to root](' .. module.paths.root ..
  '/' .. module.paths.out ..
  '/README.md)\n\n[string]: https://www.lua.org/manual/5.1/manual.html#5.4\n' ..
  '[table]: https://www.lua.org/manual/5.1/manual.html#5.5\n\n' ..
  '[' .. o.classname .. ']: #' .. o.classname:lower()
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


--[[ Second prep
> o (table) output
> f (table) field
]]
local function prepareField(o, f)
  o.header:write('\n  - **[' .. o.classname .. '][].' .. f.name)
  o.body:write('\n&rarr; `' .. f.name .. '`')
  if f.typing then
    o.header:write(' : [' .. f.typing .. '][]')
    o.body:write(' **[' .. f.typing .. '][]**')
  end
  if f.default then
    if f.default == '' then
      o.header:write(' = _nil_')
      o.body:write(' _[optional]_')
    else
      o.header:write(' = ' .. f.default)
      o.body:write(' _[' .. f.default .. ']_')
    end
  end
  if f.description then
    o.header:write('**\n    - `' .. f.description .. '`')
    o.body:write('\n`' .. f.description .. '`')
  else
    o.header:write('**')
  end
  o.body:write('\n')
end


--[[ Third prep
> o (table) output
> m (table) method
]]
local function prepareMethods(o, m)
  dump(m)
  m.name = m.name:gsub('^' .. o.modname, o.classname)
  o.header:write('  - **[' .. m.name .. '][]**')
  o.body:write('\n### ' .. m.name .. '\n')
  o.footer:write('\n[' .. m.name .. ']: #' ..
    m.name:lower():gsub('%p', '') .. '\n')
  o.header:write('\n')
  if m.title then
    o.header:write('    - `' .. m.title .. '`\n')
    o.body:write('\n' .. m.title .. '\n')
  end
  for name, method in pairs(m.params) do
  end
end


--[[ Write file
> filePath (string)
> outPath (string)
> module (table)
]]
function fileWriter.write(filePath, module)
  local data = module.files[filePath]
  local file = writer.open(module.paths.out .. '/' .. data.reqpath .. '.md')
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
        prepareModule(output, returns, t, module)
        break
      end
      -- extract methods
      for name, f in pairs(data.functions) do
        f.name = name
        if name:find(output.modname .. '%p') == 1 then
          output.methods[f.order] = f
        end
      end
      -- prepare output
      for name, field in pairs(output.fields) do
        field.name = name
        prepareField(output, field)
      end
      output.header:write('\n- _Methods_\n')
      for _, method in pairs(output.methods) do
        prepareMethods(output, method)
      end
      break
    end
  end

  file:write(output.header.text .. output.body.text .. output.footer.text)
  file:close()
  --dump(output)
end


return fileWriter
