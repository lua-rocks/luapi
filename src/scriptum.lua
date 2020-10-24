--[[
@title lua-scriptum
@version 1.0
@description Lua based document generator;
The output files are in markdown syntax.

@authors Charles Mallah
@copyright (c) 2020 Charles Mallah
@license MIT license (mit-license.org)

@warning This module will use 'Love2D' for the filesystem if you are using that framework;
Otherwise the basic Lua file-io will be used for ead/write, and system calls for file scanning.
In this case, you must provide an absolute path to the input source code, and the output
folder must already exist (please create yourself in code or manually). For the Love2D option
everything will be handled automatically.

@sample Output is in markdown
`This document was created with this module, view the source file to see example input
`And see the raw readme.md for example output

@example Generate all documentation from the root directory
`local scriptum = require("scriptum")
`scriptum.start()

For non Love2D use make sure you give the absolute path to the source root, and make
sure the output folder 'scriptum' in this example already exists in the source path, such as:
`local scriptum = require("scriptum")
`engine.scriptum.start("C:/Users/me/Desktop/codebase", "scriptum")

@example Create an optional header vignette with a comment block.
Start from the first line of the source file, and use these tags (all optional):

- **(a)title** the name of the file/module (once, single line)
- **(a)version** the current version (once, single line)
- **(a)description** module description (once, multiple lines)
- **(a)warning** module warning (multiple entries, multiple lines)
- **(a)authors** the authors (once, single line)
- **(a)copyright** the copyright line (once, single line)
- **(a)license** the license (once, single line)
- **(a)sample** provide sample outputs (multiple entries, multiple lines)
- **(a)example** provide usage examples (multiple entries, multiple lines)

Such as the following:

`(start)
`(a)title Test Module
`(a)version 1.0
`(a)authors Mr. Munki
`(a)example Import and run with start()
``local module = require("testmodule")
``module.start()
`(end)

Backtic is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.

@example Create an API function entry with a comment block and one of more of:
`(a)param name (typing) <default> [note]
and
`(a)return name (typing) [note]

Such as:

`(start)My function for documentation
`(a)param name (typing) <required> [File will be created and overwritten]
`(a)param verbose (boolean) <default: true> [More output if true]
`(a)return success (boolean) [Fail will be handled gracefully and return false]
`(end)
`function module.startModule(name, verbose)
`  local success = false
`  -- sample code --
`  return success
`end

Where:

- **name** is the parameter or return value
- optional **(typing)** such as (boolean), (number), (function), (string)
- optional **\<default\>** is the default value; if optional put \<nil\>; or \<required\> if so
- optional **[note]** is any further information

@example The markup used in this file requres escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- And **()** with **a** is used to escape the @ symbol.
- Angled brackets are escaped with \\< and \\>
]]

--[[ Configuration ]]--

local rootInput = ""
local outPath = "scriptum"
local codeSourceType = ".lua"
local outputType = ".md"
local allowLoveFilesystem = true

--[[ Locals ]]--

local love = love -- luacheck: ignore
local string, table = string, table
local module = {}

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
local subpatternCode = "`"..anyText
local patternAt = "@"..anyText
local patternLeadingSpace = spaceChar.."*"..anyText
local toRoot = "Back to root"
local tags = {
  "title", "version", "description", "authors", "copyright", "license",
  "warning", "sample", "example"
}

local function systemCheck()
  local check = package.config:sub(1, 1)
  if check == "\\" or check == "\\\\" then
    return "windows"
  end
  return "linux"
end

local function strReplace(stringIn, tag, replace)
  return stringIn:gsub(tag, replace)
end

local function recursivelyDelete(item)
  if love.filesystem.getInfo(item, "directory") then
    for _, child in pairs(love.filesystem.getDirectoryItems(item)) do
      recursivelyDelete(item .. '/' .. child)
      love.filesystem.remove(item .. '/' .. child)
    end
  end
  love.filesystem.remove(item)
end

local function recursiveFileSearch(folder, fileTree)
  if not fileTree then
    fileTree = {}
  end
  if not folder then
    folder = ""
  end
  if folder:sub(1, 1) == "/" then
    folder = folder:sub(2, #folder)
  elseif folder:sub(1, 2) == "\\\\" then
    folder = folder:sub(3, #folder)
  end
  if folder:sub(1, 1) == "." then -- Ignore hidden folder
    return fileTree
  end
  local filesTable = love.filesystem.getDirectoryItems(folder)
  for _, v in ipairs(filesTable) do
    local fullpath = folder.."/"..v
    local info = love.filesystem.getInfo(fullpath)
    if info then
      if info.type == "file" then
        if fullpath:sub(1, 1) == "/" then
          fullpath = fullpath:sub(2, #fullpath)
        end
        fileTree[#fileTree + 1] = fullpath
      else
        if info.type == "directory" then
          fileTree = recursiveFileSearch(fullpath, fileTree)
        end
      end
    end
  end
  return fileTree
end

local function scanDir(folder, fileTree)
  if not fileTree then
    fileTree = {}
  end
  if folder then
    folder = strReplace(folder, "\\\\", "/")
    folder = strReplace(folder, "\\", "/")
  end
  local pfile
  -- Files --
  local command
  if systemCheck() == "windows" then
    command = 'dir "'..folder..'" /b /a-d-h'
  else
    command = 'ls -p "'..folder..'" | grep -v /'
  end
  pfile = io.popen(command)
  for item in pfile:lines() do
    fileTree[#fileTree + 1] = folder.."/"..item
  end
  pfile:close()
  -- Folders --
  if systemCheck() == "windows" then
    command = 'dir "'..folder..'" /b /ad-h'
  else
    command = 'ls -p "'..folder..'" | grep /'
  end
  pfile = io.popen(command)
  for item in pfile:lines() do
    item = strReplace(item, "\\", "")
    fileTree = scanDir(folder.."/"..item, fileTree)
  end
  pfile:close()
  return fileTree
end

local function sortStrings(tableOfStrings)
  table.sort(tableOfStrings, function(a, b) return a:upper() < b:upper() end)
end

local function filterFiles(fileTree, fileType)
  local set = {}
  local count = 0
  local typeSize = #fileType
  for i = 1, #fileTree do
    local name = fileTree[i]
    local typePart = string.sub(name, #name - typeSize + 1, #name)
    if typePart == fileType then
      name = string.sub(name, 1, #name - typeSize)
      count = count + 1
      set[count] = name
    end
  end
  return set
end

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

local function extractRequires(lines, startLine, data)
  local search1, result1 = searchForPattern(lines, startLine, 1, patternRequire)
  local search2 = searchForPattern(lines, startLine, 1, "scriptum")
  if search1 and not search2 then
    data.requires[#data.requires + 1] = "/"..result1..codeSourceType
  end
end

local function extractParam(paramset, lines, startLine, j)
  local match, line = searchForPattern(lines, startLine + j, 1, patternParam)
  if match then
    local par = {}
    local name = string.match(line, patternTextToSpace)
    if name then
      par.name = name
    end
    local typing = string.match(line, patternTextInBrackets)
    if typing then
      par.typing = typing
    end
    local default = string.match(line, patternTextInAngled)
    if default then
      par.default = default
    end
    local note = string.match(line, patternTextInSquare)
    if note then
      par.note = note
    end
    paramset.pars[#paramset.pars + 1] = par
  end
end

local function extractReturn(paramset, lines, startLine, j)
  local match, line = searchForPattern(lines, startLine + j, 1, patternReturn)
  if match then
    local par = {}
    local name = string.match(line, patternTextToSpace)
    if name then
      par.name = name
    end
    local typing = string.match(line, patternTextInBrackets)
    if typing then
      par.typing = typing
    end
    local default = string.match(line, patternTextInAngled)
    if default then
      par.default = default
    end
    local note = string.match(line, patternTextInSquare)
    if note then
      par.note = note
    end
    paramset.returns[#paramset.returns + 1] = par
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
      local paramset = {pars = {}, returns = {}, line = startLine, desc = result2b}
      local fnL, fnLine = searchForPattern(lines, startLine + search3, 1, patternFunction)
      if fnL then
        paramset.name = fnLine
      end
      -- Function details --
      if search3 then
        for j = 1, search3 do
          extractParam(paramset, lines, startLine, j)
          extractReturn(paramset, lines, startLine, j)
        end
      end
      data.api[#data.api + 1] = paramset
    end
  end
end

local function firstToUpper(text)
  return (text:gsub("^%l", string.upper))
end

local function removeLeadingSpaces(text)
  return string.match(text, patternLeadingSpace)
end

local function multiLineField(set, field, data)
  if not set[field] then
    set[field] = {}
  else
    set[field][#set[field] + 1] = "||"
  end
  local text = removeLeadingSpaces(data)
  if text ~= "" then
    set[field][#set[field] + 1] = text
  end
end

local function catchMultilineEnd(set, multilines, multilineStarted)
  for i = 1, #multilines do
    set[multilineStarted][#set[multilineStarted] + 1] = multilines[i]
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
    set.title = removeLeadingSpaces(title)
    return "title"
  end
  local version = string.match(line2, patternVersion)
  if version then
    set.version = removeLeadingSpaces(version)
    return "version"
  end
  local authors = string.match(line2, patternAuthors)
  if authors then
    set.authors = removeLeadingSpaces(authors)
    return "authors"
  end
  local copyright = string.match(line2, patternCopyright)
  if copyright then
    set.copyright = removeLeadingSpaces(copyright)
    return "copyright"
  end
  local license = string.match(line2, patternLicense)
  if license then
    set.license = removeLeadingSpaces(license)
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
            local text = removeLeadingSpaces(line)
            -- if text ~= "" then
            multilines[#multilines + 1] = text
            -- end
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

--[[Will force a repeated header on a line that is '||', as code for a manual new line]]
local function writeVignette(output, set, fields)
  local codeBlockOpened = false
  for i = 1, #fields do
    local field = fields[i]
    if set[field] then
      output:write("\n**"..firstToUpper(field).."**:")
      if type(set[field]) == "table" then
        local count = 0
        for j = 1, #set[field] do
          local text = set[field][j]
          text = strReplace(text, "%(a%)", "@")
          text = strReplace(text, "%(start%)", "--[[")
          text = strReplace(text, "%(end%)", "]]")
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
                -- output:write("\n")
                codeBlockOpened = false
              end
              output:write("\n"..text)
            end
          end
        end
      else
        output:write("\n"..set[field])
      end
      output:write("\n")
    end
  end
end

local function stripOutRoot(text)
  if rootInput == "" then
    return text
  end
  local cleanRootInput = rootInput
  cleanRootInput = strReplace(cleanRootInput, "\\\\", "/")
  cleanRootInput = strReplace(cleanRootInput, "\\", "/")
  text = strReplace(text, cleanRootInput.."/", "")
  text = strReplace(text, cleanRootInput, "")
  return text
end

local function generateItemName(file)
  local outFilename = file
  outFilename = stripOutRoot(outFilename)
  return outFilename
end

local function outputMDFile(file)
  local outFilename = file..outputType
  outFilename = stripOutRoot(outFilename)
  outFilename = strReplace(outFilename, "/", ".")
  outFilename = strReplace(outFilename, codeSourceType, "")
  return outFilename
end

local function generateItemLink(file)
  local out = outputMDFile(file)
  return out
end

local function readFileLines(file)
  local count = 0
  local lines = {}
  if allowLoveFilesystem and love and love.filesystem then
    for line in love.filesystem.lines(file) do
      count = count + 1
      lines[count] = line
    end
  else
    for line in io.lines(file) do
      count = count + 1
      lines[count] = line
    end
  end
  return lines, count
end

local function openFileWriter(outFilename)
  local fileWriter
  if allowLoveFilesystem and love and love.filesystem then
    fileWriter = love.filesystem.newFile(outFilename)
    local opened = fileWriter:open("w")
    if not opened then
      print("error: failed to create '"..outFilename.."'")
      return nil
    end
  else
    fileWriter = io.open(outFilename, "w+")
    if not fileWriter then
      print("error: failed to create '"..outFilename.."'")
      return
    end
  end
  return fileWriter
end

local function generateReadme()
  local outFilename = outPath.."/readme.md"
  local fileWriter = openFileWriter(outFilename)
  if not fileWriter then
    return
  end
  fileWriter:write("# Project Code Documentation")
  fileWriter:write("\n")
  fileWriter:write("\n## Index")
  fileWriter:write("\n")
  for i = 1, #module.sortSet do
    local data = module.fileData[module.sortSet[i]]
    local name = generateItemName(data.file)
    local link = generateItemLink(data.file)
    fileWriter:write("\n+ ["..name.."]("..link..")")
  end
end

local function printFn(fileWriter, v3)
  fileWriter:write(" (")
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
      if v4.default ~= "required" and v4.default ~= "r" then
        cat = cat.."\\*"
      end
    end
  end
  fileWriter:write(cat)
  fileWriter:write(")")
  if v3.returns then
    fileWriter:write(" : ")
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
    fileWriter:write(cat)
  end
  fileWriter:write("  \n")
end

local function printParams(fileWriter, v3)
  for _, v4 in pairs(v3.pars) do
    local text2 = "> &rarr; "
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
    fileWriter:write(text2)
    fileWriter:write("  \n")
  end
end

local function printReturns(fileWriter, v3)
  for _, v4 in pairs(v3.returns) do
    local text2 = "> &larr; "
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
    fileWriter:write(text2)
    fileWriter:write("  \n")
  end
end

local function generateDoc(data)
  local outFilename = outputMDFile(data.file)
  outFilename = outPath.."/"..outFilename
  local fileWriter = openFileWriter(outFilename)
  if not fileWriter then
    return
  end

  if data.header then
    fileWriter:write("# Vignette\n")
    writeVignette(fileWriter, data.header, tags)
    fileWriter:write("\n")
  else
    local file = generateItemName(data.file)
    fileWriter:write("# "..file)
    fileWriter:write("\n")
  end

  -- Requires --
  local hasREQ = false
  for _, v2 in pairs(data.requires) do
    if not hasREQ then
      fileWriter:write("\n## Requires")
      fileWriter:write("\n")
      hasREQ = true
    end
    local file = v2
    if file:sub(1, 1) == "/" then
      file = file:sub(2, #file)
    elseif file:sub(1, 2) == "\\\\" then
      file = file:sub(3, #file)
    end
    local name = generateItemName(file)
    local link = generateItemLink(file)
    fileWriter:write("\n+ ["..name.."]("..link..")")
  end
  if hasREQ then
    fileWriter:write("\n")
  end

  -- API --
  local hasAPI = false
  local count = 0
  for _, v3 in pairs(data.api) do
    if v3.name then
      if not hasAPI then
        fileWriter:write("# API")
        fileWriter:write("\n")
        hasAPI = true
      end
      count = count + 1
      local nameText = strReplace(v3.name, "module.", "")
      fileWriter:write("\n**"..removeLeadingSpaces(nameText).."**")
      if v3.pars then
        printFn(fileWriter, v3)
      end
      if v3.desc then
        fileWriter:write("\n")
        fileWriter:write("> "..v3.desc)
        fileWriter:write("  \n")
      end
      if v3.pars then
        printParams(fileWriter, v3)
      end
      if v3.returns then
        printReturns(fileWriter, v3)
      end
    end
  end
  fileWriter:write("\n# Project\n")
  fileWriter:write("\n+ ["..toRoot.."](readme.md)")
  fileWriter:close()
end

local function prepareOutput()
  module.fileData = {}
  module.sortSet = {}
  if allowLoveFilesystem and love and love.filesystem then
    recursivelyDelete(outPath)
    love.timer.sleep(1)
    love.filesystem.createDirectory(outPath)
  end
end

local function parseFile(file)
  module.fileData[file] = { file = file, requires = {}, api = {} }
  local data = module.fileData[file]
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
end

--[[ Functions ]]--

--[[Start document generation
@param rootPath (string) <default: ""> [Path to read source code from]
@param outputPath (string) <default: "scriptum"> [Path to output to]
]]
function module.start(rootPath, outputPath)
  -- Prep --
  if rootPath then
    rootInput = rootPath
  end
  if outputPath then
    outPath = outputPath
  end
  prepareOutput()

  -- Parse --
  local fileTree
  if allowLoveFilesystem and love and love.filesystem then
    fileTree = recursiveFileSearch(rootInput)
  else
    fileTree = scanDir(rootInput)
  end
  local files = filterFiles(fileTree, codeSourceType)
  sortStrings(files)
  local fileCount = #files
  for i = 1, fileCount do
    local file = files[i]..codeSourceType
    parseFile(file)
  end

  -- Output order --
  local count = 0
  for k, _ in pairs(module.fileData) do
    count = count + 1
    module.sortSet[count] = k
  end
  sortStrings(module.sortSet)

  -- Generate markdown--
  generateReadme()
  for i = 1, count do
    local data = module.fileData[module.sortSet[i]]
    generateDoc(data)
  end
end

--[[ End ]]--
return module
