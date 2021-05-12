--[[
@title Test Module
@version 1.0
@authors Mr. Munki
@example Import and run with start()
`local module = require("testmodule")
`module.start()
]]

local module = {}

--[[My function for documentation
@param name (typing) <required> [File will be created and overwritten]
@param verbose (boolean) <default: true> [More output if true]
@return success (boolean) [Fail will be handled gracefully and return false]
]]
function module.startModule(name, verbose)
  local success = false
  -- sample code --
  return success
end

package.path = package.path .. ';src/?.lua'

local scriptum = require 'scriptum'

scriptum.start('/home/luarocks/repo/scriptum/src', '.')
