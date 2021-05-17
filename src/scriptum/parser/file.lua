--[[ File Parser ]]--


local fileParser = {}


local comment = "%-%-"
local anyText = "(.*)"
local spaceChar = "%s"
local anyQuote = "\""
local openBracket = "%("
local closeBracket = "%)"
local openBlockComment = "%-%-%[%["
local closeBlockComment = "%]%]"
local startBlockComment = openBlockComment..anyText
local endBlockComment = anyText..closeBlockComment
local patternRequire = "require"..openBracket..anyQuote..anyText..anyQuote..closeBracket
local patternUnpack = "@"..spaceChar..anyText
local patternFunction = "function"..anyText..openBracket
local patternLeadingSpace = spaceChar.."*"..anyText


--[[ Remove spaces or other chars from the beginning and the end of string
str (string)
chars (string) [" "]
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
local function searchForPattern(lines, startLine, forLines, pattern)
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
> set (table)
> multilines (table)
> multilineStarted ("description")
]]
local function catchMultilineEnd(set, multilines, multilineStarted)
  for i = 1, #multilines do
    set[multilineStarted][#set[multilineStarted] + 1] = multilines[i]
  end
end


--[[
> set (table)
> field ("description")
> data (string) module name
]]
local function multiLineField(set, field, data)
  if not set[field] then
    set[field] = {}
  else
    set[field][#set[field] + 1] = "||"
  end
  local text = data:match(patternLeadingSpace)
  if text ~= "" then
    set[field][#set[field] + 1] = text
  end
end


--[[
> set (table)
> line (string)
> multilines (table)
> multilineStarted (boolean)
< found ("description"|nil)
]]
local function searchForTitle(set, line, multilines, multilineStarted)
  local title = line:match(startBlockComment)
    :gsub(spaceChar, "")
    :gsub(closeBlockComment, "")
    :gsub(comment, "")
  if title then
    if multilineStarted then
      catchMultilineEnd(set, multilines, multilineStarted)
    end
    multiLineField(set, "description", title)
    return "description"
  end
  return nil
end


--[[
> lines (table)
> startLine 0
> data (table)
]]
local function extractHeaderBlock(lines, startLine, data)
  if not searchForPattern(lines, startLine, 1, startBlockComment) then return end

  local search = searchForPattern(lines, startLine, 500, endBlockComment)
  local set = {}
  if search then
    set.endHeader = search
    local multilineStarted = nil
    local multilines = {}
    local matched = searchForTitle(set, lines[1], multilines, multilineStarted)
    if matched then
      multilineStarted = matched
      multilines = {}
    end
    for j = 1, search - 2 do
      local line = lines[startLine + j + 1]
      if multilineStarted then
        local text = line:match(patternLeadingSpace)
        multilines[#multilines + 1] = text
      end
    end
    if multilineStarted then -- On end block, but check if a multiline catch wasn't done --
      catchMultilineEnd(set, multilines, multilineStarted)
    end
  end
  data.header = set
end


--[[
> file (string) full path to lua file
]]
local function readFileLines(file)
  local count = 0
  local lines = {}
  for line in io.lines(file) do
    count = count + 1
    lines[count] = line
  end
  return lines, count
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
> lines (table)
> startLine (integer)
> data (table)
]]
local function extractRequires(lines, startLine, data)
  local search1, result1 = searchForPattern(lines, startLine, 1, patternRequire)
  local search2 = searchForPattern(lines, startLine, 1, "scriptum")
  if search1 and not search2 then
    data.requires[#data.requires + 1] = "/"..result1
  end
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
  local match, line =
    searchForPattern(lines, startLine + j, 1, pattern..spaceChar..anyText)
  if match then
    if not fnSet[which] then
      fnSet[which] = {}
    end
    local par = {}
    local n, m
    n = line:find(spaceChar)
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
  local match, line = searchForPattern(lines, startLine + j, 1, patternUnpack)
  if match then
    local ret = {}
    if not fnSet.unpack then
      fnSet.unpack = {}
    end
    ret.name = line:match(patternLeadingSpace)
    local findUnpack = searchForPattern(lines, 1, 500, "local "..line.." = {")
    if findUnpack then
      local endUnpack = searchForPattern(lines, findUnpack + 1, 100, "^}$")
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
  local search2b, result2b = searchForPattern(lines, startLine, 1, startBlockComment)
  if not search2b then return end

  local search3 = searchForPattern(lines, startLine, 10, endBlockComment)
  -- Functions --
  local fnSet = {pars = nil, returns = nil, unpack = nil, line = startLine,
    desc = result2b:gsub(closeBlockComment, ""):gsub(comment, "")
  }
  fnSet.desc=trim(fnSet.desc)
  if fnSet.desc == "" then fnSet.desc = nil end
  local fnL, fnLine = searchForPattern(lines, startLine + search3, 1, patternFunction)
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


--[[
> file (string) path to file
< data ({"file"=string,"requires"=table,"api"=table})
]]
function fileParser.parse(file)
  local data = { file = file, requires = {}, api = {} }
  local lines, count = readFileLines(file)
  for i = 1, count do
    if i == 1 then
      extractHeaderBlock(lines, 0, data)
    end
    if not data.header or (not data.header.endHeader or i > data.header.endHeader) then
      extractRequires(lines, i, data)
      extractFunctionBlock(lines, i, data)
    end
  end
  return data
end


return fileParser
