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
local fileWriter = require 'writer.file'
local module = {}


local anyText = "(.*)"
local spaceChar = "%s"
local comment = " --"
local commaComment = ", --"
local patternUnpackComment = anyText..commaComment..anyText
local patternUnpackComment2 = anyText..spaceChar..comment..anyText
local subpatternCode = "~"..anyText
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
  module.files = {}

  -- Parse --

  module.files = projParser.getFiles(rootPath, config.codeSourceType)
  for _, f in ipairs(module.files) do module.fileData[f] = fileParser.parse(f) end

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
    for i = 1, #module.files do
      local data = module.fileData[module.files[i]]
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
      file:write("# "..(data.header.title or "Vignette").."\n")
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

  for index, _ in ipairs(module.files) do
    generateDoc(module.fileData[module.files[index]])
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
