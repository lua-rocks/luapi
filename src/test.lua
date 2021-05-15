--[[
@title Test Module

Import and run with start()

~local module = require("testmodule")
~module.start()
]]

local module = {}

--[[My function for documentation
@param name (typing) [File will be created and overwritten]
@param verbose (boolean) <> [More output if true]
@return success (boolean) [Fail will be handled gracefully and return false]
]]
function module.startModule(name, verbose)
  local success = false
  if verbose then print(name) end
  return success
end

package.path = package.path .. ';src/scriptum/?.lua'

local scriptum = require 'scriptum'

scriptum.start('/home/luarocks/repo/scriptum/src')

return module
