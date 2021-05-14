--[[
@title File Parser
]]


local fileParser = {}


--[[ Search for first pattern in multiply lines.
@param lines ({integer=string}) [list of lines]
@param startLine (integer) [all lines before will be ignored]
@param forLines (integer) [all lines after will be ignored]
@param pattern (string) [search for this]
@return line (integer) <nil> [line number where pattern was found]
@return result (string) <nil> [matched result]
]]
function fileParser.searchForPattern(lines, startLine, forLines, pattern)
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


return fileParser
