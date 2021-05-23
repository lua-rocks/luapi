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


local function warning(warntype, id, name, func, path)
  if warntype == 'WARNING' then
    local r = '%{reset yellow}'
    if id == 1 then
      print(colors(
        '%{yellow blink bright}' .. warntype .. '!' .. r .. ' Argument ' ..
        '%{bright}' .. name .. r .. ' type not defined in function ' ..
        '%{bright}'  .. func .. r .. ' at %{blue bright underline}' .. path
      ))
    elseif id == 2 then
      print(colors(
        '%{yellow blink bright}' .. warntype .. '!' .. r .. ' Function ' ..
        '%{bright}'  .. func .. r .. ' is not described at ' ..
        '%{blue bright underline}' .. path
      ))
    end
  elseif warntype == 'ERROR' then
    local r = '%{reset red}'
    if id == 1 then
      print(colors(
        '%{red blink bright}' .. warntype .. '!' .. r .. ' Argument ' ..
        '%{bright}' .. name .. r .. ' mismatch in function ' ..
        '%{bright}'  .. func .. r .. ' at %{blue bright underline}' .. path
      ))
    end
  end
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
  local str = content:match('%-%-%[%[(.-)[%]\n]')
  if str then data.title = trim(str) end

  -- parse description
  data.description = content:match('%-%-%[%[(.-)%]%]')
  if data.description then
    data.description = trim((data.description:gsub('^.-\n', '')))
    if data.description == data.title then data.description = nil end
  end

  local api = {
    -- {integer=string,integer=table,...}
    -- fields = {},
    -- tables = {},
    functions = {},
  }

  -- iterate functions with comments
  local order = 1
  for block in content:gmatch('[%G](%-%-%[%[.-%]%].-function.-)\n') do

    -- extract function name
    local func = block:match('%]%].-function%s(.-)%s?%(')
    api.functions[func] = {params = {}, order = order}

    -- extract args from real function definitions
    local real_args = {}
    for all in block:gmatch('%]%]\n.-function%s.-%((.-)%)') do
      for real in all:gmatch('%S+') do
        real = real:gsub('[,%s]', '')
        table.insert(real_args, real)
      end
    end

    -- parse lines from description
    local last = api.functions[func].params
    for line in block:gmatch('\n(.*)\n') do
      -- extract args from description lines
      local line_number = 1
      for arg in line:gmatch('>%s?(.-)\n') do
        local name = arg:match('^(.-)%s')
        last[name] = {
          typing = arg:match('%((.-)%)'),
          default = arg:match('%s%[(.-)%]'),
          description = trim((arg:gsub('^.*[%]%)]', ''))),
          order = line_number
        }

        if last[name].default == ''
        or last[name].default == 'nil'
        or last[name].default == 'opt' then
          last[name].default = 'optional'
        end

        if last[name].typing == nil then
          warning('WARNING', 1, name, func, data.path)
        end

        line_number = line_number + 1
      end
    end

    -- search for undescribed functions


    -- check if all args described
    for _, name in pairs(real_args) do
      if not last[name] then
        warning('ERROR', 1, name, func, data.path)
      end
    end
    for name in pairs(last) do
      local function search(t, s)
        for index, value in ipairs(t) do
          if value == s then return index end
        end
        return nil
      end
      if not search(real_args, name) then
        warning('ERROR', 1, name, func, data.path)
      end
    end

    order = order + 1
  end

  data.api = api

  --dump(data.api)
  return data
end


return fileParser
