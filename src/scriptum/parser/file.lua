--[[ File Parser ]]--


local fileParser = {}


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
    functions = {}
  }

  -- iterate functions with comments
  for block in content:gmatch('[%G](%-%-%[%[.-%]%].-function.-)\n') do

    -- extract function name
    table.insert(api.functions, block:match('%]%].-function%s(.-)%s?%('))

    -- extract args from description
    for arg in block:gmatch('\n>%s?(.-)%s') do
      -- print(arg)
    end

    -- extract real args

  end

  data.api = api

  dump(data)
  return data
end


return fileParser
