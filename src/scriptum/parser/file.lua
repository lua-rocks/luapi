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
> argname (string)
> path (string)
]]
local function warning(warntype, id, name, argname, path)
  if warntype == 'WARNING' then
    local r = '%{reset yellow}'
    if id == 1 then
      print(colors(
        '%{yellow blink bright}' .. warntype .. '!' .. r .. ' Argument ' ..
        '%{bright}' .. argname .. r .. ' type not defined in ' ..
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
> api (table) where to save data
> name (string) [] name of the described variable
> order (integer) order to print in writer module
]]
local function parseUniversal(block, path, api, name, order)
  -- initialize structure
  api[name] = {params = {}, returns = {}, order = order}

  -- parse title
  local title = block:match('%-%-%[%[(.-)[%]\n]')
  if title then api.title = trim(title) end

  -- parse muliline markdown description
  api.description = block:match('%-%-%[%[(.-)[%]><]')
  if api.description then
    api.description = trim((api.description:gsub('^.-\n', '')))
    if api.description == api.title or api.description == '' then
      api.description = nil
    end
  end

  -- parse description block line by line and extract tagged data
  local line_number = 1
  for tag, tagged_line in block:gmatch('([><])%s?(.-)\n') do
    local tagged_name = tagged_line:match('^(.-)%s')

    local tagged_table -- where to save tagged line data
    if tag == '>' then tagged_table = api[name].params
    elseif tag == '<' then tagged_table = api[name].returns end

    -- extract data for any tags
    tagged_table[tagged_name] = {
      typing = tagged_line:match('%((.-)%)'),
      default = tagged_line:match('%s%[(.-)%]'),
      description = trim((tagged_line:gsub('^.*[%]%)]', ''))),
      order = line_number
    }

    -- correct defaults
    local def = tagged_table[tagged_name].default
    if def == '' or def == 'nil' or def == 'opt' then
      tagged_table[tagged_name].default = ''
    end

    -- correct all
    for key, value in pairs(tagged_table[tagged_name]) do
      if value == '' and key ~= 'default' then
        tagged_table[tagged_name][key] = nil
      end
    end

    -- warn params with undescribed type
    if tag == '>' then
      if tagged_table[tagged_name].typing == nil then
        warning('WARNING', 1, name, tagged_name, path)
      end
    end

    line_number = line_number + 1
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
  parseUniversal(block, path, api, name, order)
  local params = api[name].params

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
      warning('ERROR', 1, name, argname, path)
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
      warning('ERROR', 1, name, argname, path)
    end
  end
end


--[[ Parse table
> api (table) save api here
> name (string) real name of the table
> block (string) block of comments
> order (integer) number of this commented block
> path (string) path to parsed file
]]
local function parseTable(api, name, block, order, path)
  parseUniversal(block, path, api, name, order)
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
      name = last:match('[%s\n](.-)%s?=%s?{')
      if name then
        api.tables = api.tables or {}
        parseTable(api.tables, name, block, order, path)
      end
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
    if not described then warning('WARNING', 2, name, nil, path) end
  end

  return data
end


return fileParser
