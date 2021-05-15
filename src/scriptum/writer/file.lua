--[[ File Writer ]]--


local writer = require 'writer.writer'
local fileWriter = {}


local anyText = "(.*)"
local spaceChar = "%s"
local comment = " --"
local commaComment = ", --"
local patternUnpackComment = anyText..commaComment..anyText
local patternUnpackComment2 = anyText..spaceChar..comment..anyText
local subpatternCode = "~"..anyText
local patternLeadingSpace = spaceChar.."*"..anyText
local toRoot = "Back to root"
local tags = {"description"}


--[[
Will force a repeated header on a line that is '||', as code for a manual new line
]]
local function writeVignette(output, set, fields)
  local function firstToUpper(text)
    return (text:gsub("^%l", string.upper))
  end
  local codeBlockOpened = false
  for i = 1, #fields do
    local field = fields[i]
    if set[field] then
      local count = 0
      local maximum = #set[field]
      for j = 2, maximum do
        local text = set[field][j]
        text = text:gsub("%(a%)", "@")
        text = text:gsub("%(start%)", "--[[")
        text = text:gsub("%(end%)", "]]")
        count = count + 1
        if text == "||" then
          output:write("\n")
          output:write("\n**"..firstToUpper(field).."**:")
          count = 0
        else
          local code = string.match(text, subpatternCode)
          if code then
            if count == 2 then
              output:write("\n")
            end
            output:write("\n    "..code)
            codeBlockOpened = true
          else
            if codeBlockOpened then
              codeBlockOpened = false
            end
            output:write("\n"..text)
          end
        end
      end
      output:write("\n")
    end
  end
end


local function printFn(f, v3)
  f:write(" (")
  local cat = ""
  local count = 0
  for _, v4 in pairs(v3.pars) do
    if v4.name then
      count = count + 1
      if count > 1 then
        cat = cat..", "..v4.name
      else
        cat = cat..v4.name
      end
      if not v4.default then
        cat = cat.."\\*"
      end
    end
  end
  f:write(cat..")")
  if v3.returns then
    f:write(" : ")
    cat = ""
    count = 0
    for _, v4 in pairs(v3.returns) do
      if v4.name then
        count = count + 1
        if count > 1 then
          cat = cat..", "..v4.name
        else
          cat = cat..v4.name
        end
      end
    end
    f:write(cat)
  end
  f:write("  \n")
end


local function printParamsOrReturns(f, v3, which)
  for _, v4 in pairs(v3[which]) do
    local text2
    if which == "pars" then
      text2 = "> &rarr; "
    else
      text2 = "> &larr; "
    end
    if v4.name then
      text2 = text2.."**"..v4.name.."**"
    end
    if v4.typing then
      text2 = text2.." ("..v4.typing..")"
    end
    if v4.default then
      text2 = text2.." <*"..v4.default.."*>"
    end
    if v4.note then
      text2 = text2.." `"..v4.note.."`"
    end
    f:write(text2.."  \n")
  end
end


local function printUnpack(f, v3)
  for _, v4 in pairs(v3.unpack) do
    if v4.lines then
      for i = 1, #v4.lines do
        local line = v4.lines[i]
        local comment1 = string.match(line, patternUnpackComment)
        local comment2 = string.match(line, patternUnpackComment2)
        if comment1 then
          f:write("> - "..comment1:match(patternLeadingSpace))
          local stripped = line:gsub(comment1, "")
          stripped = stripped:gsub(commaComment, "")
          stripped = stripped:gsub("-", ""):match(patternLeadingSpace)
          f:write(" `"..stripped.."`  \n")
        elseif comment2 then
          f:write("> - "..comment2:match(patternLeadingSpace))
          local stripped = line:gsub(comment2, "")
          stripped = stripped:gsub(comment, "")
          stripped = stripped:gsub("-", ""):match(patternLeadingSpace)
          f:write(" `"..stripped.."`  \n")
        else
          f:write("> - "..line:gsub(",", ""):match(patternLeadingSpace).."  \n")
        end
      end
    end
  end
  f:write(">  \n")
end


function fileWriter.write(rootPath, outPath, config, module, data)
  local outFilename = writer.makeOutputFileName(data.file, config, rootPath)
  outFilename = outPath.."/"..outFilename
  local file = writer.open(outFilename)
  if not file then return end

  if data.header then
    file:write("# "..(data.header.description[1] or "Vignette").."\n")
    writeVignette(file, data.header, tags)
    file:write("\n")
  else
    writer.stripOutRoot(data.file, rootPath):write("# "..file.."\n")
  end

  -- Requires --
  local hasREQ = false
  for _, v2 in pairs(data.requires) do
    if not hasREQ then
      file:write("\n# Requires\n")
      hasREQ = true
    end
    if v2:sub(1, 1) == "/" then
      v2 = v2:sub(2, #v2)
    elseif v2:sub(1, 2) == "\\\\" then
      v2 = v2:sub(3, #v2)
    end
    local name = writer.stripOutRoot(v2, rootPath)
    local link = writer.makeOutputFileName(v2, config, rootPath)
    local isInternal = false
    if module.fileData[v2] then
      isInternal = true
    end
    if isInternal then
      v2:write("\n+ ["..name.."]("..link..")")
    else
      v2:write("\n+ "..name.."")
    end
  end
  if hasREQ then
    file:write("\n")
  end

  -- API --
  local hasAPI = false
  local count = 0
  for _, v3 in pairs(data.api) do
    if v3.name then
      if not hasAPI then
        file:write("\n## API\n")
        hasAPI = true
      end
      count = count + 1
      local nameText = v3.name:gsub("module.", "")
      file:write("\n**"..nameText:match(patternLeadingSpace).."**")
      if v3.pars then
        printFn(file, v3)
      end
      if v3.desc then
        file:write("\n> "..v3.desc.."  \n>\n")
      end
      if v3.pars then
        printParamsOrReturns(file, v3, 'pars')
      end
      if v3.unpack then
        printUnpack(file, v3)
      end
      if v3.returns then
        file:write(">\n")
        printParamsOrReturns(file, v3, 'returns')
      end
    end
  end
  file:write("\n## Project\n\n+ ["..toRoot.."](README.md)\n")
  file:close()
end


return fileWriter
