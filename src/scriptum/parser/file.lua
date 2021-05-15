--[[
@title File Parser
]]


local fileParser = {}


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
local patternInsideBlockComment = openBlockComment..anyText..closeBlockComment
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
local patternTitle = "@title"..anyText
local patternVersion = "@version"..anyText
local patternDesc = "@description"..anyText
local patternWarning = "@warning"..anyText
local patternExample = "@example"..anyText
local patternSample = "@sample"..anyText
local patternAuthors = "@authors"..anyText
local patternCopyright = "@copyright"..anyText
local patternLicense = "@license"..anyText
local patternAt = "@"..anyText
local patternLeadingSpace = spaceChar.."*"..anyText


--[[ Search for first pattern in multiply lines.
@param lines ({integer=string}) [list of lines]
@param startLine (integer) [all lines before will be ignored]
@param forLines (integer) [all lines after will be ignored]
@param pattern (string) [search for this]
@return line (integer) <nil> [line number where pattern was found]
@return result (string) <nil> [matched result]
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


local function searchForMultilineTaggedData(set, line, multilines, multilineStarted)
  local description = string.match(line, patternDesc)
  if description then
    if multilineStarted then
      catchMultilineEnd(set, multilines, multilineStarted)
    end
    multiLineField(set, "description", description)
    return "description"
  end
  local warning = string.match(line, patternWarning)
  if warning then
    if multilineStarted then
      catchMultilineEnd(set, multilines, multilineStarted)
    end
    multiLineField(set, "warning", warning)
    return "warning"
  end
  local sample = string.match(line, patternSample)
  if sample then
    if multilineStarted then
      catchMultilineEnd(set, multilines, multilineStarted)
    end
    multiLineField(set, "sample", sample)
    return "sample"
  end
  local example = string.match(line, patternExample)
  if example then
    if multilineStarted then
      catchMultilineEnd(set, multilines, multilineStarted)
    end
    multiLineField(set, "example", example)
    return "example"
  end
  return nil
end


local function searchForTaggedData(line2, set)
  local title = string.match(line2, patternTitle)
  if title then
    set.title = title:match(patternLeadingSpace)
    return "title"
  end
  local version = string.match(line2, patternVersion)
  if version then
    set.version = version:match(patternLeadingSpace)
    return "version"
  end
  local authors = string.match(line2, patternAuthors)
  if authors then
    set.authors = authors:match(patternLeadingSpace)
    return "authors"
  end
  local copyright = string.match(line2, patternCopyright)
  if copyright then
    set.copyright = copyright:match(patternLeadingSpace)
    return "copyright"
  end
  local license = string.match(line2, patternLicense)
  if license then
    set.license = license:match(patternLeadingSpace)
    return "license"
  end
  return nil
end


local function extractHeaderBlock(lines, startLine, data)
  local search = searchForPattern(lines, startLine, 1, startBlockComment)
  if search then
    local search3 = searchForPattern(lines, startLine, 500, endBlockComment)
    local set = {}
    if search3 then
      set.endHeader = search3
      local multilineStarted = nil
      local multilines = {}
      for j = 1, search3 - 2 do
        local paramLineN = searchForPattern(lines, startLine + j, 1, patternAt)
        if paramLineN then -- Line is prefixed with '@' --
          local line = lines[startLine + j + paramLineN]
          local matched = searchForMultilineTaggedData(set, line, multilines, multilineStarted)
          if matched then
            multilineStarted = matched
            multilines = {}
          else
            local otherTagMatch = searchForTaggedData(line, set)
            if otherTagMatch and multilineStarted then
              catchMultilineEnd(set, multilines, multilineStarted)
              multilineStarted = nil
              multilines = {}
            end
          end
        else -- Line is not prefixed with '@' --
          local line = lines[startLine + j + 1]
          if multilineStarted then
            local text = line:match(patternLeadingSpace)
            multilines[#multilines + 1] = text
          end
        end
      end
      if multilineStarted then -- On end block, but check if a multiline catch wasn't done --
        catchMultilineEnd(set, multilines, multilineStarted)
      end
    end
    data.header = set
  end
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
    par.default = string.match(line, patternTextInAngled)
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
    ret.default = string.match(line, patternTextInAngled)
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
  local search2 = searchForPattern(lines, startLine, 1, patternInsideBlockComment)
  if search2 then
    data.api[#data.api + 1] = {line = startLine}
  else
    local search2b, result2b = searchForPattern(lines, startLine, 1, startBlockComment)
    if search2b then
      local search3 = searchForPattern(lines, startLine, 10, endBlockComment)
      -- Functions --
      local fnSet = {pars = nil, returns = nil, unpack = nil, line = startLine, desc = result2b}
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
  end
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
