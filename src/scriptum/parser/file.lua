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


--[[ Read file and return its content as string
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


--[[ Print some colored warning in terminal
> warntype (string)
> id (any)
> name (string)
> func (string)
> path (string)
]]
local function warning(warntype, id, name, path, func)
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


--[[ Common operations for any description block
> block (string) block of text description
> path (string) path to parsed file
> params (table) where to save data
> func (string) [] name of the function (if it's a function)
]]
local function parseUniversal(block, path, params, func)
  -- TODO parse title and description
  print(block)
  -- parse description block line by line and extract tagged data
  for line in block:gmatch('\n(.*)\n') do
    local line_number = 1
    for arg in line:gmatch('>%s?(.-)\n') do
      local name = arg:match('^(.-)%s')
      params[name] = {
        typing = arg:match('%((.-)%)'),
        default = arg:match('%s%[(.-)%]'),
        description = trim((arg:gsub('^.*[%]%)]', ''))),
        order = line_number
      }

      if params[name].default == ''
      or params[name].default == 'nil'
      or params[name].default == 'opt' then
        params[name].default = 'optional'
      end

      for key, value in pairs(params[name]) do
        if value == '' then params[name][key] = nil end
      end

      if params[name].typing == nil then
        warning('WARNING', 1, name, func, path)
      end

      line_number = line_number + 1
    end
  end
end


--[[ Parse function
> api (table) save api here
> func (string) name of the function
> block (string) block of comments
> last (string) one line of code after comments
> order (integer) number of this commented block
> path (string) path to parsed file
]]
local function parseFunction(api, func, block, last, order, path)
  api.functions[func] = {params = {}, order = order}
  local params = api.functions[func].params

  parseUniversal(block, path, params, func)

  -- extract args from real function definitions
  local real_args = {}
  for all in last:gmatch('.-function%s.-%((.-)%)') do
    for real in all:gmatch('%S+') do
      real = real:gsub('[,%s]', '')
      table.insert(real_args, real)
    end
  end

  -- check if all args described
  for _, name in pairs(real_args) do
    if not params[name] then
      warning('ERROR', 1, name, func, path)
    end
  end
  for name in pairs(params) do
    local function search(t, s)
      for index, value in ipairs(t) do
        if value == s then return index end
      end
      return nil
    end
    if not search(real_args, name) then
      warning('ERROR', 1, name, func, path)
    end
  end
end


--[[ Parse table
> api (table) save api here
> block (string) block of comments
> last (string) one line of code after comments
> order (integer) number of this commented block
> path (string) path to parsed file
]]
local function parseTable(api, block, last, order, path)
end


--[[ Parse comments block and extract api
> content (string) file content
> api (table) save api here
> path (string) path to the file
]]
local function parseComments(content, api, path)
  local order = 1
  for block, last in content:gmatch('(%-%-%[%[.-%]%]\n)(.-)\n') do
    local func = last:match('function%s(.-)%s?%(')
    if func then
      api.functions = api.functions or {}
      parseFunction(api, func, block, last, order, path)
    else
      api.tables = api.tables or {}
      parseTable(api, block, last, order, path)
    end
    order = order + 1
  end
end


--[[ Parse .lua file and create a table with its detailed description
> path (string) path to file
< data (table) full parsed info
]]
function fileParser.parse(path)
  local data = {
    requires = {},
    api = nil,
    title = nil,
    description = nil,
  }

  local api = {}

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
    if data.description == data.title or data.description == '' then
      data.description = nil
    end
  end

  parseComments(content, api, path)

  -- search for undescribed functions
  for func in code:gmatch('\nl?o?c?a?l?%s?function%s(.-)%s?%(') do
    local described
    for key in pairs(api.functions) do
      if key == func then described = true break end
    end
    if not described then warning('WARNING', 2, nil, func, path) end
  end

  data.api = api

  return data
end


return fileParser
