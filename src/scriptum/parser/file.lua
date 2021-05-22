--[[ File Parser ]]--
local fileParser = {}


local colors = require 'ansicolors'


--[[ Remove spaces or other chars from the beginning and the end of string
> str (string)
> chars (string) [" "]
]]
local function trim(str, chars)
  if not chars then return str:match("^[%s]*(.-)[%s]*$") end
  chars = chars:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
  return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end


--[[
> path (string)
< content (string)
]]
local function readFile(path)
  local file = io.open(path, 'rb')
  if not file then return nil end
  local content = file:read '*a'
  file:close()
  return content
end


--[[
> path (string) path to file
< data (table) full parsed info
]]
function fileParser.parse(path)
  local data = {
    path = path,
    requires = {},
    api = nil,
    title = nil,
    description = nil,
  }

  -- extract raw file content
  local content = readFile(path)

  -- create no comments version
  local code = content:gsub('%-%-%[%[.-%]%]', ''):gsub('%-%-.-\n', '')

  -- parse requires
  for found in code:gmatch('[%G]require%s*%(?%s*[\'\"](.-)[\'\"]') do
    table.insert(data.requires, found)
  end

  -- parse title
  data.title = trim(content:match('%-%-%[%[(.-)[%]\n]'))

  -- parse description
  data.description = content:match('%-%-%[%[(.-)%]%]'):gsub('^.-\n', '')
  data.description = trim(data.description)
  if data.description == data.title then data.description = nil end

  local api = {
    -- {integer=string,integer=table,...}
    -- fields = {},
    -- tables = {},
    functions = {},
  }

  -- iterate functions with comments
  for block in content:gmatch('[%G](%-%-%[%[.-%]%].-function.-)\n') do

    -- extract function name
    local func = block:match('%]%].-function%s(.-)%s?%(')
    table.insert(api.functions, func)
    table.insert(api.functions, {})

    -- extract args from real function definitions
    local real_args = {}
    for all in block:gmatch('%]%]\n.-function%s.-%((.-)%)') do
      for real in all:gmatch('%S+') do
        real = real:gsub('[,%s]', '')
        table.insert(real_args, real)
      end
    end

    -- parse lines from description
    local last = api.functions[#api.functions]
    for line in block:gmatch('\n(.*)\n') do
      -- extract args from description lines
      for arg in line:gmatch('>%s?(.-)\n') do
        local name = arg:match('^(.-)%s')
        table.insert(last, name)
        table.insert(last, {
          typing = arg:match('%((.-)%)'),
          default = arg:match('%s%[(.-)%]'),
          description = trim((arg:gsub('^.*[%]%)]', ''))),
        })
        last = last[#last]

        if last.default == ''
        or last.default == 'nil'
        or last.default == 'opt' then
          last.default = 'optional'
        end

        if last.typing == nil then
          local r = '%{reset yellow}'
          print(colors('%{yellow blink bright}WARNING!' .. r .. ' Argument ' ..
          '%{bright}' .. name .. r .. ' type not defined in function ' ..
          '%{bright}'  .. func .. r .. ' at %{blue bright underline}' ..
          data.path))
        end

        local found = block:find('function%s.-%(%w*%s*,?%s*' ..
          name .. '[%s,)]')
        if not found then
          local r = '%{reset red}'
          print(colors('%{red blink bright}ERROR!' .. r .. ' Argument ' ..
          '%{bright}' .. name .. r .. ' mismatch in function ' ..
          '%{bright}'  .. func .. r .. ' at %{blue bright underline}' ..
          data.path))
        end
      end
    end
  end

  data.api = api

  dump(data.api)
  return data
end


return fileParser
