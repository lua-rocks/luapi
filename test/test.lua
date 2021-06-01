--[[ Test Module
Import and run with start()
```lua
local module = require "testmodule"
module.start()
```
    I'm <not> a [code]
> test (string) [] some module field
< Module (table) `module` is a class `Module` extended from `table`
]]
local module = {}


--[[ My function for documentation
Additional **muliline** description
in `markdown` _format_ supported in any block.
> name (typindg) file will be created and overwritten
> verbose (boolean) [] more output if true
< success (boolean) fail will be handled gracefully and return false
< test (ololo) ddd
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
local luapi = require 'luapi'


-- generate full project documetation (excluding libraries)
luapi.start('/home/luarocks/repo/luapi', {'src/luapi'})

-- generate minimal doc just for quick test
-- luapi.start('/home/luarocks/repo/luapi', {'test'})

-- run "lua test.lua dump" for dump
if ({...})[1] == 'dump' then dump(luapi, {depth = 7}) end


return module
