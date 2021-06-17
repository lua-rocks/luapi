--[[ File Writer ]]--
local fileWriter = {}


local writer = require 'writer'


--[[ First prep
> o (table) output
> m (table) module
]]
local function prepareModule(o, m)
  o.fields = m.params
  o.body.text = '\n### ' .. m.returns.name .. '\n'
  o.header.text = '# ' .. m.title .. '\n'
  if m.description then o.header:write('\n' .. m.description .. '\n') end
  o.header:write('\n## Contents\n')
  o.footer:write(
    '/README.md)\n\n[string]: https://www.lua.org/manual/5.1/manual.html#5.4\n'
    .. '[table]: https://www.lua.org/manual/5.1/manual.html#5.5\n\n'
  )
  o.footer:write('[' .. m.returns.name .. ']: #' .. m.returns.name:lower())
  o.header:write('\n- _Fields_\n  - **[' .. m.returns.name .. '][]')
  if m.returns.typing then
    o.header:write(' : [' .. m.returns.typing .. '][]**')
    o.body:write('\nExtends: **[' .. m.returns.typing .. '][]**\n')
  else
    o.header:write('**')
  end
  o.body:write('\nRequires: **none**\n')
  o.header:write('\n    - `No requirements`')
end


--[[ Second prep
> o (table) output
> f (table) field
> m (table) module
]]
local function prepareField(o, f, m)
  o.header:write('\n  - **[' .. m.returns.name .. '][].' .. f.name)
  o.body:write('\n&rarr; `' .. f.name .. '`')
  if f.typing then
    o.header:write(' : ' .. f.typing .. '')
    o.body:write(' **' .. f.typing .. '**')
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
  if f.title then
    o.header:write('**\n    - `' .. f.title .. '`')
    o.body:write('\n`' .. f.title .. '`')
  else
    o.header:write('**')
  end
  o.body:write('\n')
end


--[[ Third prep
> o (table) output
> m (table) method
> mod (table) module
]]
local function prepareMethods(o, m, mod)
  -- WARNING probably I must add sorting here but it looks like already sorted
  local orderedReturns = {}
  for name, ret in pairs(m.returns or {}) do
    orderedReturns[ret.order] = ret
    orderedReturns[ret.order].name = name
  end

  m.name = m.name:gsub('^' .. mod.name, mod.returns.name)
  o.header:write('  - **[' .. m.name .. '][] (')
  local first = true
  for name, arg in pairs(m.params or {}) do
    if not first then o.header:write(', ') end
    o.header:write(name)
    if not arg.default then o.header:write('\\*') end
    first = false
  end
  o.header:write(')')
  first = true
  for _, ret in pairs(orderedReturns) do
    if first then
      o.header:write(' : ')
    else
      o.header:write(', ')
    end
    o.header:write(ret.typing)
    first = false
  end
  o.header:write('**')
  o.body:write('\n### ' .. m.name .. '\n')
  o.footer:write('\n[' .. m.name .. ']: #' ..
    m.name:lower():gsub('%p', '') .. '\n')
  o.header:write('\n')
  if m.title then
    o.header:write('    - `' .. m.title .. '`\n')
    o.body:write('\n' .. m.title .. '\n')
  end
  if m.description then
    o.body:write('\n> ' .. m.description:gsub('\n', '\n> ') .. '\n')
  end
  local function universal(name, any)
    o.body:write('`' .. name .. '`')
    if any.typing then
      o.body:write(' : **' .. any.typing .. '**')
    end
    if any.default then
      if any.default == '' then
        any.default = 'optional'
      end
      o.body:write(' _[' .. any.default .. ']_')
    end
    if any.title then
      o.body:write('\n`' .. any.title .. '`')
    end
  end
  for name, arg in pairs(m.params or {}) do
    o.body:write('\n&rarr; ')
    universal(name, arg)
    o.body:write('\n')
  end
  for _, ret in pairs(orderedReturns) do
    o.body:write('\n&larr; ')
    universal(ret.name, ret)
    o.body:write('\n')
  end
end


--[[ Write file
> reqPath (string)
> module (table)
]]
function fileWriter.write(reqPath, module)
  local data = module.files[reqPath]
  if not data.module then return end

  local file = writer.open(module.config.outPath .. '/' .. reqPath .. '.md')
  if not file then return end
  local write = function(self, text) self.text = self.text .. text end
  local output = {
    methods = {},
    header = { write = write },
    body = { write = write },
    footer = { write = write },
  }

  output.footer.text = '\n## Footer\n\n[Back to root](' ..
  module.config.rootPath .. '/' .. module.config.outPath
  data.module.returns = data.module.returns or {}
  data.module.returns.name = data.module.returns.name or data.module.name
  prepareModule(output, data.module)
  -- extract methods
  for name, f in pairs(data.functions) do
    f.name = name
    if name:find(data.module.name .. '%p') == 1 then
      output.methods[f.order] = f
    end
  end
  for name, field in pairs(output.fields or {}) do
    field.name = name
    prepareField(output, field, data.module)
  end
  output.header:write('\n- _Methods_\n')
  for _, method in pairs(output.methods or {}) do
    prepareMethods(output, method, data.module)
  end

  file:write(output.header.text .. output.body.text .. output.footer.text)
  file:close()
end


return fileWriter
