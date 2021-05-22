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
    names = {
      fields = {},    -- ({integer=string}) field names by order
      tables = {},    -- ({integer=string}) table names by order
      functions = {}, -- ({integer=string}) func  names by order
    },
    args = {},        -- ({string=table}) func args by func names
    returns = {},     -- ({string=table}) func returns by func names
  }

  -- iterate functions with comments
  for block in content:gmatch('[%G](%-%-%[%[.-%]%].-function.-)\n') do

    -- extract function name
    local func = block:match('%]%].-function%s(.-)%s?%(')
    table.insert(api.names.functions, func)
    api.args[func] = {}
    api.returns[func] = {}

    -- parse lines from description
    local fargs = api.args[func]
    for line in block:gmatch('\n(.*)\n') do
      -- extract args from description lines
      for arg in line:gmatch('>%s?(.-)\n') do
        table.insert(fargs, {
          name = arg:match('^(.-)%s'),
          typing = arg:match('%((.-)%)'),
          default = arg:match('%s%[(.-)%]'),
        })
        local last = fargs[#fargs]
        if last.default == ''
        or last.default == 'nil'
        or last.default == 'opt' then
          last.default = 'optional'
        end
        if last.typing == nil then
          local r = '%{reset yellow}'
          print(colors('%{red bright}WARNING!' .. r .. ' Argument ' ..
          '%{bright}' .. last.name .. r .. ' type not defined in function ' ..
          '%{bright}'  .. func .. r .. ' at %{blue bright underline}' ..
          data.path .. r))
        end
      end
    end

    -- extract real args
    print(block)
    local real = {}
  end

  data.api = api

  -- dump(data.api)
  return data
end


return fileParser
