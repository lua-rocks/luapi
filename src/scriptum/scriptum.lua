--[[
@title Scriptum

Output is in markdown

~This document was created with this module, view the source file to see example input
~And see the raw readme.md for example output

Generate all documentation from the root directory:

```lua
local scriptum = require "scriptum"
scriptum.start()
```

For non Love2D use make sure you give the absolute path to the source root, and make
sure the output folder 'scriptum' in this example already exists in the source path, such as:

```lua
local scriptum = require "scriptum"
scriptum.start("C:/Users/me/Desktop/codebase", "scriptum")
```

Create an optional header vignette with a comment block.
Start from the first line of the source file, and use these tags (all optional):

- **(a)title** the name of the file/module (once, single line)

Such as the following:

~(start)
~(a)title Test Module
~Import and run with start()
~  local module = require "testmodule"
~  module.start()
~(end)

Backtic is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.

Create an API function entry with a comment block and one of more of:

~(a)param name (typing) <default> [note]

and:

~(a)return name (typing) [note]

Such as:

```lua
(start)My function for documentation
(a)param name (typing) <required> [File will be created and overwritten]
(a)param verbose (boolean) <default: true> [More output if true]
(a)return success (boolean) [Fail will be handled gracefully and return false]
(end)
function module.startModule(name, verbose)
  local success = false
  -- sample code --
  return success
end
```

Where:

- **name** is the parameter or return value
- optional **(typing)** such as (boolean), (number), (function), (string)
- optional **\<default\>** is the default value; if optional put \<nil\>, \<opt\> or \<\>
- optional **[note]** is any further information

Additionally, the (a)unpack tag can be used to automatically unpack a simple table with key/value
pairs, where each line is one pair ah a comment describing the key. This is used, for example, with
the module 'config'. The tag in that case is used as:

~(a)unpack config

The mark-up used in this file requires escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- And **()** with **a** is used to escape the @ symbol.
- Angled brackets are escaped with \\< and \\>

Override a configuration parameter programmatically; insert your override values into a
new table using the matched key names:

```lua
local overrides = { codeSourceType = ".lua" }
scriptum.configuration(overrides)
```

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
@param rootPath (string) <""> [Path to read source code from]
@param outPath (string) <"scriptum"> [Path to output to]
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
  for i, _ in ipairs(module.files) do
    fileWriter.write(rootPath, outPath, config, module, module.fileData[module.files[i]])
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
