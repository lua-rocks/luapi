--[[
@title Helpers
]]


local help = {}


--[[ Table ]]--


function help.deepCopy(input)
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


--[[ String ]]--


--[[ Other ]]--


return help
