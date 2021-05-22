--[[ File Parser ]]--


local fileParser = {}


-- TODO remove
local p = {}
p.comment = "%-%-"
p.anyText = "(.*)"
p.spaceChar = "%s"
p.openBlockComment = "%-%-%[%["
p.closeBlockComment = "%]%]"
p.startBlockComment = p.openBlockComment..p.anyText
p.endBlockComment = p.anyText..p.closeBlockComment
p.require = "require"..p.spaceChar..p.anyText
p.unpack = "@"..p.spaceChar..p.anyText
p.func = "function"..p.anyText.."%("
p.leadingSpace = p.spaceChar.."*"..p.anyText


--[[ Remove spaces or other chars from the beginning and the end of string
> str (string)
> chars (string) [" "]
]]
local function trim(str, chars)
  if not chars then return str:match("^[%s]*(.-)[%s]*$") end
  chars = chars:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
  return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end


--[[ Search for first pattern in multiply lines.
> lines ({integer=string}) list of lines
> startLine (integer) all lines before will be ignored
> forLines (integer) all lines after will be ignored
> pattern (string) search for this
< line (integer) [] line number where pattern was found
< result (string) [] matched result
]]
local function multilineSearch(lines, startLine, forLines, pattern)
  local count = #lines
  for j = 1, forLines do
    local k = startLine + j
    if k <= count then
      local line3 = string.match(lines[k], pattern)
      if line3 then
        return j, line3
      end
    end
  end
  return nil, nil
end


--[[
> opt (string)
< opt (string)
]]
local function correctOpt(opt)
  if opt == "" or opt == "nil" or opt == "opt" then
    opt = "optional"
  end
  return opt
end


--[[
> fnSet (table)
> lines (table)
> startLine (integer)
> j (integer)
> which ("pars"|"returns")
]]
local function extractFunctionComments(fnSet, lines, startLine, j, which)
  local pattern
  if which == "pars" then pattern = ">" else pattern = "<" end
  local match, line = multilineSearch(lines, startLine + j, 1,
    pattern..p.spaceChar..p.anyText)
  if match then
    if not fnSet[which] then
      fnSet[which] = {}
    end
    local par = {}
    local n, m
    n = line:find(p.spaceChar)
    par.name = line:sub(1, n-1)
    m = line:find("(", n, true)
    if m then
      n = line:find(")", n, true)
      par.typing = line:sub(m+1, n-1)
    end
    m = line:find("[", n, true)
    if m then
      n = line:find("]", n, true)
      par.default = correctOpt(line:sub(m+1, n-1))
    end
    par.note = trim(line:sub(n+1, -1))
    if par.note == '' then par.note = nil end
    fnSet[which][#fnSet[which] + 1] = par
  end
end


--[[
> fnSet (table)
> lines (table)
> startLine (integer)
> j (integer)
]]
local function extractUnpack(fnSet, lines, startLine, j)
  local match, line = multilineSearch(lines, startLine + j, 1, p.unpack)
  if match then
    local ret = {}
    if not fnSet.unpack then
      fnSet.unpack = {}
    end
    ret.name = line:match(p.leadingSpace)
    local findUnpack = multilineSearch(lines, 1, 500, "local "..line.." = {")
    if findUnpack then
      local endUnpack = multilineSearch(lines, findUnpack + 1, 100, "^}$")
      if endUnpack then
        ret.lines = {}
        for i = findUnpack + 2, findUnpack + endUnpack do
          ret.lines[#ret.lines + 1] = lines[i]
        end
      end
    end
    fnSet.unpack[#fnSet.unpack + 1] = ret
  end
end


--[[
> lines (table)
> startLine (integer)
> data (table)
]]
local function extractFunctionBlock(lines, startLine, data)
  local search2b, result2b = multilineSearch(lines, startLine, 1, p.startBlockComment)
  if not search2b then return end

  local search3 = multilineSearch(lines, startLine, 10, p.endBlockComment)
  -- Functions --
  local fnSet = {pars = nil, returns = nil, unpack = nil, line = startLine,
    desc = result2b:gsub(p.closeBlockComment, ""):gsub(p.comment, "")
  }
  fnSet.desc=trim(fnSet.desc)
  if fnSet.desc == "" then fnSet.desc = nil end
  local fnL, fnLine = multilineSearch(lines, startLine + search3, 1, p.func)
  if fnL then
    fnSet.name = trim(fnLine)
  end
  -- Function details --
  if search3 then
    for j = 1, search3 do
      extractFunctionComments(fnSet, lines, startLine, j, "pars")
      extractFunctionComments(fnSet, lines, startLine, j, "returns")
      extractUnpack(fnSet, lines, startLine, j)
    end
  end
  data.api[#data.api + 1] = fnSet
end


-- Version 2 (WIP) --


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
    api = {},
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

  -- TODO extractFunctionBlock



  dump(data)
  return data
end


return fileParser
