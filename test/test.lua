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
> name (typindg) file will be created and overwritten
> verbose (boolean) [] more output if true
< success (boolean) fail will be handled gracefully and return false
]]
function module.startModule(name, verbose)
  local success = false
  if verbose then print(name) end
  return success
end


-- luarocks install inspect
inspect = require 'inspect'


--[[ Print lua-object internals
> ... (any) thing to inspect
]]
function dump(...) print(inspect(...)) end


package.path = package.path .. ';src/?.lua;src/?/init.lua'
local scriptum = require 'scriptum'


-- generate full project documetation (excluding libraries)
-- scriptum.start('/home/luarocks/repo/scriptum', {'src/scriptum'})

-- generate minimal doc just for quick test
scriptum.start '/home/luarocks/repo/scriptum/test'


if ({...})[1] == 'dump' then dump(scriptum) end


return module
