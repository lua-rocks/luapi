--[[ Scriptum
Output is in markdown.

~This document was created with this module, view the source file to see example input
~And see the raw readme.md for example output

Generate all documentation from the root directory:

```lua
local scriptum = require "scriptum"
scriptum.start()
```

Make sure you give the absolute path to the source root, and make
sure the output folder 'doc' in this example already exists in the source path, such as:

```lua
local scriptum = require "scriptum"
scriptum.start("C:/Users/me/Desktop/codebase", "doc")
```

Create a block comment with a tittle in the first line:

~(start) Test Module
~Import and run with start()
~~  local module = require "testmodule"
~~  module.start()
~(end)

Tilde is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.

Create an API function entry with a comment block and one of more of:

~> name (typing) [default] note

and:

~< name (typing) note

Such as:

```lua
(start) My function for documentation
> name (typing) file will be created and overwritten
> verbose (boolean) [true] more output if true
< success (boolean) fail will be handled gracefully and return false
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
- optional **\[default\]** is the default value; if optional put \[nil\], \[opt\] or \[\]
- optional **note** is any further information

Additionally, the **(a)** tag can be used to automatically unpack a simple table with key/value
pairs, where each line is one pair ah a comment describing the key. This is used, for example, with
the module 'config'. The tag in that case is used as:

~(a) config

The mark-up used in this file requires escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- And **()** with **a** is used to escape the @ symbol.
- Angled brackets are escaped with \\< and \\>

Override a configuration parameter programmatically; insert your override values into a
new table using the matched key names:

```lua
local overrides = { outPath = "doc" }
scriptum.configuration(overrides)
```
]]


local config = {
  rootPath = "", -- search files here
  outPath = "doc", -- generate output here
}


local projParser = require 'src.scriptum.parser.proj'
local fileParser = require 'src.scriptum.parser.file'
local projWriter = require 'src.scriptum.writer.proj'
local fileWriter = require 'src.scriptum.writer.file'
local module = {}


--[[ Start document generation
> rootPath (string) [""] path to read source code from
> outPath (string) ["scriptum"] path to output to
< model (table) project model can be used for autocomlete in an IDE
]]
function module.start(rootPath, outPath)
  rootPath = rootPath or config.rootPath
  outPath = outPath or config.outPath
  module.fileData = {}
  module.files = {}

  -- Parse --
  module.files = projParser.getFiles(rootPath)
  for _, f in ipairs(module.files) do module.fileData[f] = fileParser.parse(f) end

  -- Generate markdown--
  projWriter.write(rootPath, outPath, module)
  for i, _ in ipairs(module.files) do
    fileWriter.write(rootPath, outPath, module.fileData[module.files[i]])
  end

  return module
end


--[[ Modify the configuration of this module programmatically
Provide a table with keys that share the same name as the configuration parameters:
> overrides (table) each key is from a valid name, the value is the override
@ config
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
