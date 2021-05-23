--[[ Scriptum
Output is in markdown.

  This document was created with this module, view the source file to see
  example input And see the raw readme.md for example output

Generate all documentation from the root directory:

```lua
local scriptum = require "scriptum"
scriptum.start()
```

Make sure you give the absolute path to the source root, and make sure the
output folder 'doc' in this example already exists in the source path, such as:

```lua
local scriptum = require "scriptum"
scriptum.start "C:/Users/me/Desktop/codebase"
```

Create a block comment with a tittle in the first line:

  (start) Test Module
  Import and run with start()
    local module = require "testmodule"
    module.start()
  (end)

Tilde is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.

Create an API function entry with a comment block and one of more of:

  > name (typing) [default] note

and:

  < name (typing) note

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
- optional **[default]** is the default value; if optional put [nil], [opt] or []
- optional **note** is any further information

Additionally, the **(a)** tag can be used to automatically unpack a simple table with key/value
pairs, where each line is one pair ah a comment describing the key. This is used, for example, with
the module 'config'. The tag in that case is used as:

  (a) config

The mark-up used in this file requires escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- And **()** with **a** is used to escape the @ symbol.

Override a configuration parameter programmatically; insert your override values into a
new table using the matched key names:

```lua
local overrides = { outPath = "doc" }
scriptum.configuration(overrides)
```
]]
local module = {}


local config = {
  rootPath = nil, -- search files here
  pathFilters = nil, -- extra search filters
  outPath = "doc", -- generate output here
}


local projParser = require 'scriptum.parser.proj'
local fileParser = require 'scriptum.parser.file'
-- local projWriter = require 'scriptum.writer.proj'
-- local fileWriter = require 'scriptum.writer.file'


--[[ Start document generation
> rootPath (string) path to read source code from
> pathFilters (table) [] search files only in these subdirs
> outPath (string) ["doc"] path to output to
]]
function module.start(rootPath, pathFilters, outPath)
  rootPath = rootPath or config.rootPath
  pathFilters = pathFilters or config.pathFilters
  outPath = outPath or config.outPath
  module.files = {}

  -- Parse --
  local files
  files, module.reqs = projParser.getFiles(rootPath, pathFilters)
  for _, f in ipairs(files) do
    module.files[f] = fileParser.parse(f)
  end

  -- Generate markdown --
  -- projWriter.write(outPath, module)
  -- for i, _ in ipairs(module.files) do
  --   fileWriter.write(rootPath, outPath, module, i)
  -- end
end


--[[ Modify the configuration of this module programmatically
Provide a table with keys that share the same name as the configuration parameters:
> overrides (table) each key is from a valid name, the value is the override
@ config
]]
function module.configuration(overrides)
  for k, v in pairs(overrides) do
    if config[k] then config[k] = v end
  end
end


return module
