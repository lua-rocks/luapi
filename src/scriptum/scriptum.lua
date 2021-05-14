--[[
@title lua-scriptum
@version 1.0
@description Lua based document generator;
The output files are in markdown syntax.

@authors Charles Mallah
@copyright (c) 2020 Charles Mallah
@license MIT license (mit-license.org)

@warning `Love2D` is not required anymore.

@sample Output is in markdown
~This document was created with this module, view the source file to see example input
~And see the raw readme.md for example output

@example Generate all documentation from the root directory:

~local scriptum = require("scriptum")
~scriptum.start()

For non Love2D use make sure you give the absolute path to the source root, and make
sure the output folder 'scriptum' in this example already exists in the source path, such as:

~local scriptum = require("scriptum")
~scriptum.start("C:/Users/me/Desktop/codebase", "scriptum")

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

~(start)
~(a)title Test Module
~(a)version 1.0
~(a)authors Mr. Munki
~(a)example Import and run with start()
~  local module = require("testmodule")
~  module.start()
~(end)

Backtic is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.

@example Create an API function entry with a comment block and one of more of:

~(a)param name (typing) <default> [note]

and:

~(a)return name (typing) [note]

Such as:

~(start)My function for documentation
~(a)param name (typing) <required> [File will be created and overwritten]
~(a)param verbose (boolean) <default: true> [More output if true]
~(a)return success (boolean) [Fail will be handled gracefully and return false]
~(end)
~function module.startModule(name, verbose)
~  local success = false
~  -- sample code --
~  return success
~end

Where:

- **name** is the parameter or return value
- optional **(typing)** such as (boolean), (number), (function), (string)
- optional **\<default\>** is the default value; if optional put \<nil\>; or \<required\> if so
- optional **[note]** is any further information

Additionally, the (a)unpack tag can be used to automatically unpack a simple table with key/value
pairs, where each line is one pair ah a comment describing the key. This is used, for example, with
the module 'config'. The tag in that case is used as:

~(a)unpack config

@example The mark-up used in this file requires escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- And **()** with **a** is used to escape the @ symbol.
- Angled brackets are escaped with \\< and \\>

@example Override a configuration parameter programmatically; insert your override values into a
new table using the matched key names:

~local overrides = {
~                    codeSourceType = ".lua"
~                  }
~scriptum.configuration(overrides)

]]


local config = {
  codeSourceType = ".lua", -- Looking for these source code files
  outputType = ".md", -- Output file suffix
  rootPath = "", -- Search files here
  outPath = "doc", -- Generate output here
}


local projParser = require 'parser.proj'
local fileParser = require 'parser.file'
local projWriter = require 'writer.proj'
local file = require 'writer.file'
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
local comment = " --"
local commaComment = ", --"
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
local patternUnpackComment = anyText..commaComment..anyText
local patternUnpackComment2 = anyText..spaceChar..comment..anyText
local subpatternCode = "~"..anyText
local patternAt = "@"..anyText
local patternLeadingSpace = spaceChar.."*"..anyText
local toRoot = "Back to root"
local tags = {
  "title", "version", "description", "authors", "copyright", "license",
  "warning", "sample", "example"
}


--[[Start document generation
@param rootPath (string) <default: ""> [Path to read source code from]
@param outPath (string) <default: "scriptum"> [Path to output to]
]]
function module.start(rootPath, outPath)
  rootPath = rootPath or config.rootPath
  outPath = outPath or config.outPath
  module.fileData = {}
  module.sortSet = {}

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

  --[[ Recursively scan directory and return list with each file path.
  @param folder (string) [folder path]
  @param fileTree (table) <{}> [table to extend]
  @return fileTree (table) [result table]
  ]]
  local function scanDir(folder, fileTree)
    local function systemCheck()
      local check = package.config:sub(1, 1)
      if check == "\\" or check == "\\\\" then
        return "windows"
      end
      return "linux"
    end
    if not fileTree then
      fileTree = {}
    end
    if folder then
      folder = folder:gsub("\\\\", "/")
      folder = folder:gsub("\\", "/")
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
      fileTree[#fileTree + 1] = (folder.."/"..item):gsub("//", "/")
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
      item = item:gsub("\\", "")
      fileTree = scanDir(folder.."/"..item, fileTree)
    end
    pfile:close()
    return fileTree
  end

  -- Parse --
  local function parseFile(file)
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

    local function extractHeaderBlock(lines, startLine, data)
      local function catchMultilineEnd(set, multilines, multilineStarted)
        for i = 1, #multilines do
          set[multilineStarted][#set[multilineStarted] + 1] = multilines[i]
        end
      end

      local function searchForMultilineTaggedData(set, line, multilines, multilineStarted)
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

      local search = searchForPattern(lines, startLine, 1, startBlockComment)
      if search then
        local search3 = searchForPattern(lines, startLine, 500, endBlockComment)
        local set = {}
        if search3 then
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
        data.requires[#data.requires + 1] = "/"..result1..config.codeSourceType
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

  local files = filterFiles(scanDir(rootPath), config.codeSourceType)
  sortStrings(files)
  local fileCount = #files
  for i = 1, fileCount do
    local file = files[i]..config.codeSourceType
    parseFile(file)
  end

  -- Output order --
  local count = 0
  for k, _ in pairs(module.fileData) do
    count = count + 1
    module.sortSet[count] = k
  end
  sortStrings(module.sortSet)

  local function openFileWriter(filename)
    local file = io.open(filename, "w+")
    if not file then
      print("error: failed to create '"..filename.."' (openFileWriter)")
      return
    end
    return file
  end

  local function stripOutRoot(text)
    if rootPath == "" then
      return text
    end
    local cleanrootPath = rootPath
    cleanrootPath = cleanrootPath:gsub("\\\\", "/")
    cleanrootPath = cleanrootPath:gsub("\\", "/")
    text = text:gsub(cleanrootPath.."/", "")
    text = text:gsub(cleanrootPath, "")
    return text
  end

  local function outputMDFile(file)
    local outFilename = file..config.outputType
    outFilename = stripOutRoot(outFilename)
    outFilename = outFilename:gsub("/", ".")
    outFilename = outFilename:gsub(config.codeSourceType, "")
    return outFilename
  end

  -- Generate markdown--
  do
    local outFilename = outPath.."/README.md"
    local file = openFileWriter(outFilename)
    if not file then return end
    file:write("# Project Code Documentation\n\n## Index\n")
    for i = 1, #module.sortSet do
      local data = module.fileData[module.sortSet[i]]
      local name = stripOutRoot(data.file)
      local link = outputMDFile(data.file)
      file:write("\n+ ["..name.."]("..link..")\n")
    end
  end

  local function generateDoc(data)
    local outFilename = outputMDFile(data.file)
    outFilename = outPath.."/"..outFilename
    local file = openFileWriter(outFilename)
    if not file then
      return
    end

    if data.header then
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
          if field ~= "title" and set[field] then
            output:write("\n**"..firstToUpper(field).."**:")
            if type(set[field]) == "table" then
              local count = 0
              local maximum = #set[field]
              for j = 1, maximum do
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
            else
              output:write("\n"..set[field])
            end
            output:write("\n")
          end
        end
      end
      file:write("# "..(data.header.title or Vignette).."\n")
      writeVignette(file, data.header, tags)
      file:write("\n")
    else
      local file = stripOutRoot(data.file)
      file:write("# "..file.."\n")
    end

    -- Requires --
    local hasREQ = false
    for _, v2 in pairs(data.requires) do
      if not hasREQ then
        file:write("\n# Requires\n")
        hasREQ = true
      end
      local file = v2
      if file:sub(1, 1) == "/" then
        file = file:sub(2, #file)
      elseif file:sub(1, 2) == "\\\\" then
        file = file:sub(3, #file)
      end
      local name = stripOutRoot(file)
      local link = outputMDFile(file)
      local isInternal = false
      if module.fileData[file] then
        isInternal = true
      end
      if isInternal then
        file:write("\n+ ["..name.."]("..link..")")
      else
        file:write("\n+ "..name.."")
      end
    end
    if hasREQ then
      file:write("\n")
    end

    -- API --
    local function printFn(file, v3)
      file:write(" (")
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
      file:write(cat..")")
      if v3.returns then
        file:write(" : ")
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
        file:write(cat)
      end
      file:write("  \n")
    end
    local function printParams(file, v3)
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
        file:write(text2.."  \n")
      end
    end
    local function printReturns(file, v3)
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
        file:write(text2.."  \n")
      end
    end
    local function printUnpack(file, v3)
      for _, v4 in pairs(v3.unpack) do
        if v4.lines then
          for i = 1, #v4.lines do
            local line = v4.lines[i]
            local comment1 = string.match(line, patternUnpackComment)
            local comment2 = string.match(line, patternUnpackComment2)
            if comment1 then
              file:write("> - "..comment1:match(patternLeadingSpace))
              local stripped = line:gsub(comment1, "")
              stripped = stripped:gsub(commaComment, "")
              stripped = stripped:gsub("-", ""):match(patternLeadingSpace)
              file:write(" `"..stripped.."`  \n")
            elseif comment2 then
              file:write("> - "..comment2:match(patternLeadingSpace))
              local stripped = line:gsub(comment2, "")
              stripped = stripped:gsub(comment, "")
              stripped = stripped:gsub("-", ""):match(patternLeadingSpace)
              file:write(" `"..stripped.."`  \n")
            else
              file:write("> - "..line:gsub(",", ""):match(patternLeadingSpace).."  \n")
            end
          end
        end
      end
      file:write(">  \n")
    end

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
          file:write("\n> "..v3.desc.."  \n")
        end
        if v3.pars then
          printParams(file, v3)
        end
        if v3.unpack then
          printUnpack(file, v3)
        end
        if v3.returns then
          printReturns(file, v3)
        end
      end
    end
    file:write("\n## Project\n\n+ ["..toRoot.."](README.md)\n")
    file:close()
  end

  for i = 1, count do
    local data = module.fileData[module.sortSet[i]]
    generateDoc(data)
  end
end


--[[Modify the configuration of this module programmatically.
Provide a table with keys that share the same name as the configuration parameters:
@param overrides (table) [Each key is from a valid name, the value is the override]
@unpack config
]]
function module.configuration(overrides)
  local function deepCopy(input)
    if type(input) == "table" then
      local output = {}
      for i, o in next, input, nil do
        output[deepCopy(i)] = deepCopy(o)
      end
      return output
    else
      return input
    end
  end
  local safe = deepCopy(overrides)
  for k, v in pairs(safe) do
    if config[k] == nil then
      print("error: override field '"..k.."' not found (configuration)")
    else
      config[k] = v
    end
  end
end


return module