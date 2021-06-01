--[[ LUAPI

    This document was created with this module, view the source file to see
    example input And see the raw readme.md for example output.

]]

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

    Test Module
    Import and run with start()
    local module = require "testmodule"
    module.start()

Create an API function entry with a comment block and one of more of:

    > name (typing) [default] note

and:

    < name (typing) note

Such as:

```lua
--[\[ My function for documentation
(param) name (typing) file will be created and overwritten
(param) verbose (boolean) [true] more output if true
(return) success (boolean) fail will be handled gracefully and return false
(end)
function module.startModule(name, verbose)
  local success = false
  -- sample code --
  return success
--]\]
```

Where:

- **name** is the parameter or return value
- optional **(typing)** such as (boolean), (number), (function), (string)
- optional **[default]** is the default value;
  if optional put [nil], [opt] or []
- optional **note** is any further information

Additionally, the **@** tag can be used to automatically unpack a simple table
with key/value pairs, where each line is one pair ah a comment describing the
key. This is used, for example, with the module 'config'. The tag in that case
is used as:

    @ config

The mark-up used in this file requires escape symbols to generate the outputs
properly:

- Where **()** with **start** or **end** can be used to escape block comments.
- And **()** with **a** is used to escape the @ symbol.

Override a configuration parameter programmatically; insert your override values
into a new table using the matched key names:

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


local projParser = require 'luapi.parser.proj'
local fileParser = require 'luapi.parser.file'
local projWriter = require 'luapi.writer.proj'
local fileWriter = require 'luapi.writer.file'


--[[ Start document generation
> rootPath (string) path to read source code from
> pathFilters (table) [] search files only in these subdirs (relative to root)
> outPath (string) ["doc"] path to output to (relative to root)
]]
function module.start(rootPath, pathFilters, outPath)
  rootPath = rootPath or config.rootPath
  pathFilters = pathFilters or config.pathFilters
  outPath = outPath or config.outPath
  module.files = {}
  module.paths = {
    root = rootPath,
    out = outPath
  }

  -- Parse --
  local files, requires = projParser.getFiles(rootPath, pathFilters)
  for index, path in ipairs(files) do
    module.files[path] = fileParser.parse(path)
    module.files[path].reqpath = requires[index]
    module.files[path].mdpath = rootPath .. '/' .. outPath .. '/' ..
      requires[index] .. '.md'
  end

  -- Generate markdown --
  projWriter.write(outPath, module)
  for filePath in pairs(module.files) do
    fileWriter.write(filePath, module)
  end
end


--[[ Modify the configuration of this module programmatically
Provide a table with keys that share the same name as the config parameters:
> overrides (table) each key is from a valid name, the value is the override
@ config
]]
function module.configuration(overrides)
  for k, v in pairs(overrides) do
    if config[k] then config[k] = v end
  end
end


return module