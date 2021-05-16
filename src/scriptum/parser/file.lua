--[[ File Parser ]]--


local fileParser = {}


local comment = "%-%-"
local anyText = "(.*)"
local spaceChar = "%s"
local anyQuote = "\""
local openBracket = "%("
local closeBracket = "%)"
local openBracket2 = "%<"
local closeBracket2 = "%>"
local openBracket3 = "%["
local closeBracket3 = "%]"
local openBlockComment = "%-%-%[%["
local closeBlockComment = "%]%]"
local startBlockComment = openBlockComment..anyText
local endBlockComment = anyText..closeBlockComment
local patternRequire = "require"..openBracket..anyQuote..anyText..anyQuote..closeBracket
local patternParam = "@param"..spaceChar..anyText
local patternReturn = "@return"..spaceChar..anyText
local patternUnpack = "@unpack"..spaceChar..anyText
local patternTextToSpace = anyText..spaceChar..openBracket..anyText..closeBracket
local patternTextInBrackets = openBracket..anyText..closeBracket
local patternTextInAngled = openBracket2..anyText..closeBracket2
local patternTextInSquare = openBracket3..anyText..closeBracket3
local patternFunction = "function"..anyText..openBracket
local patternLeadingSpace = spaceChar.."*"..anyText


--[[ Search for first pattern in multiply lines.
@param lines ({integer=string}) [list of lines]
@param startLine (integer) [all lines before will be ignored]
@param forLines (integer) [all lines after will be ignored]
@param pattern (string) [search for this]
@return line (integer) <> [line number where pattern was found]
@return result (string) <> [matched result]
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


local function catchMultilineEnd(set, multilines, multilineStarted)
  for i = 1, #multilines do
    set[multilineStarted][#set[multilineStarted] + 1] = multilines[i]
  end
end


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


local function readFileLines(file)
  local count = 0
  local lines = {}
  for line in io.lines(file) do
    count = count + 1
    lines[count] = line
  end
  return lines, count
end


local function correctOpt(opt)
  if opt == "" or opt == "nil" or opt == "opt" then
    opt = "optional"
  end
  return opt
end


local function extractRequires(lines, startLine, data)
  local search1, result1 = searchForPattern(lines, startLine, 1, patternRequire)
  local search2 = searchForPattern(lines, startLine, 1, "scriptum")
  if search1 and not search2 then
    data.requires[#data.requires + 1] = "/"..result1
  end
end


local function extractParam(fnSet, lines, startLine, j)
  local match, line = searchForPattern(lines, startLine + j, 1, patternParam)
  if match then
    if not fnSet.pars then
      fnSet.pars = {}
    end
    local par = {}
    par.name = string.match(line, patternTextToSpace)
    par.typing = string.match(line, patternTextInBrackets)
    par.default = correctOpt(string.match(line, patternTextInAngled))
    par.note = string.match(line, patternTextInSquare)
    fnSet.pars[#fnSet.pars + 1] = par
  end
end


local function extractReturn(fnSet, lines, startLine, j)
  local match, line = searchForPattern(lines, startLine + j, 1, patternReturn)
  if match then
    if not fnSet.returns then
      fnSet.returns = {}
    end
    local ret = {}
    ret.name = string.match(line, patternTextToSpace)
    ret.typing = string.match(line, patternTextInBrackets)
    ret.default = correctOpt(string.match(line, patternTextInAngled))
    ret.note = string.match(line, patternTextInSquare)
    fnSet.returns[#fnSet.returns + 1] = ret
  end
end


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


local function extractFunctionBlock(lines, startLine, data)
  local search2b, result2b = searchForPattern(lines, startLine, 1, startBlockComment)
  if not search2b then return end

  local search3 = searchForPattern(lines, startLine, 10, endBlockComment)
  -- Functions --
  local fnSet = {pars = nil, returns = nil, unpack = nil, line = startLine,
    desc = result2b:gsub(closeBlockComment, ""):gsub(comment, "")
  }
  local fnL, fnLine = searchForPattern(lines, startLine + search3, 1, patternFunction)
  if fnL then
    fnSet.name = fnLine
  end
  -- Function details --
  if search3 then
    for j = 1, search3 do
      extractParam(fnSet, lines, startLine, j)
      extractReturn(fnSet, lines, startLine, j)
      extractUnpack(fnSet, lines, startLine, j)
    end
  end
  data.api[#data.api + 1] = fnSet
end


--[[
@param file (string) [path to file]
@return data ({"file"=string,"requires"=table,"api"=table})
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
