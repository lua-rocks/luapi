--[[ Writer ]]--
local writer = {}


--[[ Open a file to write
> filename (string) full path to the file
< file (table) io.open result
]]
function writer.open(filename)
  local file = io.open(filename, "w+")
  if not file then
    print("error: failed to create '"..filename.."'")
    return
  end
  return file
end


return writer
