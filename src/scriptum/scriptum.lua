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

  -- Generate markdown--

  projWriter.write(rootPath, outPath, config, module)


  for index, _ in ipairs(module.files) do
    fileWriter.write(rootPath, outPath, config, module, module.fileData[module.files[index]])
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
