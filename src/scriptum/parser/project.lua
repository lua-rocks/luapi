--[[
@title Project Parser
]]


local projParser = {}


--[[ Recursively scan directory and return list with each file path.
@param folder (string) [folder path]
@param fileTree (table) <{}> [table to extend]
@return fileTree (table) [result table]
]]
function projParser.scanDir(folder, fileTree)
  local function systemCheck()
    local check = package.config:sub(1, 1)
    if check == "\\" or check == "\\\\" then
      return "windows"
    end
    return "linux"
  end
  if not fileTree then
    fileTree = {}
  end
  if folder then
    folder = folder:gsub("\\\\", "/")
    folder = folder:gsub("\\", "/")
  end
  local pfile
  -- Files --
  local command
  if systemCheck() == "windows" then
    command = 'dir "'..folder..'" /b /a-d-h'
  else
    command = 'ls -p "'..folder..'" | grep -v /'
  end
  pfile = io.popen(command)
  for item in pfile:lines() do
    fileTree[#fileTree + 1] = (folder.."/"..item):gsub("//", "/")
  end
  pfile:close()
  -- Folders --
  if systemCheck() == "windows" then
    command = 'dir "'..folder..'" /b /ad-h'
  else
    command = 'ls -p "'..folder..'" | grep /'
  end
  pfile = io.popen(command)
  for item in pfile:lines() do
    item = item:gsub("\\", "")
    fileTree = projParser.scanDir(folder.."/"..item, fileTree)
  end
  pfile:close()
  print(require 'inspect'(fileTree))
  return fileTree
end

return projParser
