--[[ Test Module
Import and run with start()
```lua
local module = require "testmodule"
module.start()
```
~I'm not a code
]]

local module = {}

--[[ My function for documentation
> name (typing) file will be created and overwritten
> verbose (boolean) [] more output if true
< success (boolean) fail will be handled gracefully and return false
]]
function module.startModule(name, verbose)
  local success = false
  if verbose then print(name) end
  return success
end

-- luarocks install inspect
inspect = require 'inspect' -- luacheck: ignore

-- just in case if your path is broken (usually this is no needed)
package.path = package.path .. ';./?.lua;./?/init.lua;.\\?.lua;.\\?\\init.lua'

local scriptum = require 'src.scriptum'

-- generate full project documetation
local model = scriptum.start('/home/luarocks/repo/scriptum/src') -- luacheck: ignore

-- generate minimal doc just for quick test
-- local model = scriptum.start('/home/luarocks/repo/scriptum/test') -- luacheck: ignore

--for key, value in pairs(model.fileData) do
--  print(key)
--  print(inspect(value.api, {depth = 4})) -- luacheck: ignore
--end

return module
