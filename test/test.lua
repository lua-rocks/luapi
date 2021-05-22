--[[ Test Module
Import and run with start()
```lua
local module = require "testmodule"
module.start()
```
  I'm not a code
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

--[[ Another one function
> args (table) ololo
> nothing this should throw error
]]
local function test(args) end

-- luarocks install inspect
inspect = require 'inspect' -- luacheck: ignore
function dump(...) print(inspect(...)) end -- luacheck: ignore

package.path = package.path .. ';src/?.lua;src/?/init.lua'
local scriptum = require 'scriptum'

-- generate full project documetation
-- scriptum.start '/home/luarocks/repo/scriptum'

-- custom paths test
-- local model = scriptum.start('/home/luarocks/repo/scriptum', {
--   'src/scriptum/parser', 'test'
-- })

-- generate minimal doc just for quick test
-- local model =
scriptum.start('/home/luarocks/repo/scriptum/test')


-- for key, value in pairs(model.fileData) do
--   print(key)
--   print(inspect(value, {depth = 3}))
-- end

return module
