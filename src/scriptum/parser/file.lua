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
> argname (string)
> name (string)
> path (string)
]]
local function warning(warntype, id, argname, path, name)
  if warntype == 'WARNING' then
    local r = '%{reset yellow}'
    if id == 1 then
      print(colors(
        '%{yellow blink bright}' .. warntype .. '!' .. r .. ' Argument ' ..
        '%{bright}' .. argname .. r .. ' type not defined in function ' ..
        '%{bright}'  .. name .. r .. ' at %{blue bright underline}' .. path
      ))
    elseif id == 2 then
      print(colors(
        '%{yellow blink bright}' .. warntype .. '!' .. r .. ' Function ' ..
        '%{bright}'  .. name .. r .. ' is not described at ' ..
        '%{blue bright underline}' .. path
      ))
    end
  elseif warntype == 'ERROR' then
    local r = '%{reset red}'
    if id == 1 then
      print(colors(
        '%{red blink bright}' .. warntype .. '!' .. r .. ' Argument ' ..
        '%{bright}' .. argname .. r .. ' mismatch in function ' ..
        '%{bright}'  .. name .. r .. ' at %{blue bright underline}' .. path
      ))
    end
  end
end


--[[ Common operations for any description block
> block (string) block of text description
> path (string) path to parsed file
> api (table) where to save title and description
> params (table) where to save parameters data
> name (string) [] name of the described variable
]]
local function parseUniversal(block, path, api, params, name)
  -- parse title
  local str = block:match('%-%-%[%[(.-)[%]\n]')
  if str then api.title = trim(str) end

  -- parse muliline markdown description
  api.description = block:match('%-%-%[%[(.-)[%]><]')
  if api.description then
    api.description = trim((api.description:gsub('^.-\n', '')))
    if api.description == api.title or api.description == '' then
      api.description = nil
    end
  end

  -- parse description block line by line and extract tagged data
  for line in block:gmatch('\n(.*)\n') do
    local line_number = 1
    for arg in line:gmatch('>%s?(.-)\n') do
      local argname = arg:match('^(.-)%s')
      params[argname] = {
        typing = arg:match('%((.-)%)'),
        default = arg:match('%s%[(.-)%]'),
        description = trim((arg:gsub('^.*[%]%)]', ''))),
        order = line_number
      }

      if params[argname].default == ''
      or params[argname].default == 'nil'
      or params[argname].default == 'opt' then
        params[argname].default = 'optional'
      end

      for key, value in pairs(params[argname]) do
        if value == '' then params[argname][key] = nil end
      end

      if params[argname].typing == nil then
        warning('WARNING', 1, name, name, path)
      end

      line_number = line_number + 1
    end
  end
end


--[[ Parse function
> api (table) save api here
> name (string) name of the function
> block (string) block of comments
> last (string) one line of code after comments
> order (integer) number of this commented block
> path (string) path to parsed file
]]
local function parseFunction(api, name, block, last, order, path)
  api[name] = {params = {}, order = order}
  local params = api[name].params

  parseUniversal(block, path, api[name], params, name)

  -- extract args from real function definitions
  local real_args = {}
  for all in last:gmatch('.-function%s.-%((.-)%)') do
    for real in all:gmatch('%S+') do
      real = real:gsub('[,%s]', '')
      table.insert(real_args, real)
    end
  end

  -- check if all args described
  for _, argname in pairs(real_args) do
    if not params[argname] then
      warning('ERROR', 1, argname, name, path)
    end
  end
  for argname in pairs(params) do
    local function search(t, s)
      for index, value in ipairs(t) do
        if value == s then return index end
      end
      return nil
    end
    if not search(real_args, argname) then
      warning('ERROR', 1, argname, name, path)
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
  --api[name] = {params = {}, order = order}
  --local params = api[name].params
  --parseUniversal(block, path, api, params)
end


--[[ Parse comments block and extract api
> content (string) file content
> api (table) save api here
> path (string) path to the file
]]
local function parseComments(content, api, path)
  local order = 1
  for block, last in content:gmatch('(%-%-%[%[.-%]%]\n)(.-)\n') do
    local name = last:match('function%s(.-)%s?%(')
    if name then
      api.functions = api.functions or {}
      parseFunction(api.functions, name, block, last, order, path)
    else
      api.tables = api.tables or {}
      parseTable(api.tables, block, last, order, path)
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
  }

  -- extract raw file content
  local content = readFile(path)

  -- create no comments version
  local code = content:gsub('%-%-%[%[.-%]%]', ''):gsub('%-%-.-\n', '')

  -- parse requires
  for found in code:gmatch('[%G]require%s*%(?%s*[\'\"](.-)[\'\"]') do
    table.insert(data.requires, found)
  end

  parseComments(content, data, path)

  -- search for undescribed functions
  for name in code:gmatch('\nl?o?c?a?l?%s?function%s(.-)%s?%(') do
    local described
    for key in pairs(data.functions) do
      if key == name then described = true break end
    end
    if not described then warning('WARNING', 2, nil, name, path) end
  end

  return data
end


return fileParser
