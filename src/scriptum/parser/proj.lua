--[[ Project Parser ]]--


local projParser = {}


--[[ Recursively scan directory and return list with each file path.
> folder (string) [folder path]
> fileTree (table) <{}> [table to extend]
< fileTree (table) [result table]
]]
local function scanDir(folder, fileTree)
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
    fileTree = scanDir(folder.."/"..item, fileTree)
  end
  pfile:close()
  return fileTree
end


--[[ Select and return only those files whose extensions match.
> fileTree (table)
> ext (string)
< fileTree (table)
]]
local function filterFiles(fileTree, ext)
  local set = {}
  local count = 0
  local typeSize = #ext
  for i = 1, #fileTree do
    local name = fileTree[i]
    local typePart = string.sub(name, #name - typeSize + 1, #name)
    if typePart == ext then
      name = string.sub(name, 1, #name - typeSize)
      count = count + 1
      set[count] = name..ext
    end
  end
  return set
end


--[[ Get list of all parseable files in directory.
> path (string) [directory full path]
> ext (string) [file extension]
< files (table) [list of file paths]
]]
function projParser.getFiles(path, ext)
  local t = filterFiles(scanDir(path), ext)
  table.sort(t, function(a, b) return a:upper() < b:upper() end)
  return t
end


return projParser
