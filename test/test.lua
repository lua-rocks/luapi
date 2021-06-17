--[[ Test Module
Import and run with start()
```lua
local module = require "testmodule"
module.start()
```
    I'm <not> a [code]
> test (string) [] some module field
> files ({string=table...}) [{}] [files paths] = <parsed> (file) tables
< Test (table) `module` is a class `Test` extended from `table`
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


--[[ Test table field
ololo
ululu
> a (number)
> b (number)
< Demo (table) example class Demo, extended from table, inserted into module
]]
module.testTable = {}


-- luarocks install inspect
inspect = require 'inspect'


--[[ Print lua-object internals
> ... (any) thing to inspect
]]
function dump(...) print(inspect(...)) end


package.path = package.path .. ';src/luapi/?.lua;src/luapi/?/init.lua'
local luapi = require 'init'


luapi.start {
  rootPath = '/home/luarocks/repo/luapi',
  -- pathFilters = {'src/luapi'}, -- full project documetation (no libraries)
  pathFilters = {'test'}, -- minimal doc just for quick test
}


-- run "lua test.lua dump" for dump
if ({...})[1] == 'dump' then dump(luapi, {depth = 7}) end


return module
