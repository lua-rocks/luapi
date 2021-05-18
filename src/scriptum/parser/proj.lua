--[[ Project Parser ]]--


local projParser = {}


--[[ Convert full path to relative
> fullPath (string)
> rootPath (string)
< relativePath (string)
]]
local function stripOutRoot(fullPath, rootPath)
  if rootPath == "" then return fullPath end
  rootPath = rootPath:gsub("\\\\", "/"):gsub("\\", "/")
  fullPath = fullPath:gsub(rootPath.."/", ""):gsub(rootPath, "")
  return fullPath
end


--[[ Convert filesystem path to require path
> path (string) full path to .lua file
> rootPath (string) full path to the project root
< path (string)
]]
local function fs2reqPath(path, rootPath)
  path = stripOutRoot(path, rootPath)
  path = path
    :gsub("/", ".")
    :gsub(".lua", "")
    :gsub(".init", "")
  return path
end


--[[ Recursively scan directory and return list with each file path.
> folder (string) folder path
> fileTree (table) [{}] table to extend
< fileTree (table) result table
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


--[[ Returns a new list consisting of all the given lists concatenated into one.
> ... ({integer=any}) lists
< result ({integer=any}) concatenated list
]]
local function concat(...)
  local rtn = {}
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    if t ~= nil then
      for _, v in ipairs(t) do
        rtn[#rtn + 1] = v
      end
    end
  end
  return rtn
end


--[[ Get list of all parseable files in directory.
> rootPath (string) root directory full path
> pathFilters (table) [] search files only in these subdirs
< files ({integer=string}) list of fs-file paths
< reqs (table) list of req-file paths
]]
function projParser.getFiles(rootPath, pathFilters)
  local files = {}
  if not pathFilters or #pathFilters == 0 then
    files = filterFiles(scanDir(rootPath), '.lua')
  else
    for _, filter in ipairs(pathFilters) do
      local found = filterFiles(scanDir(rootPath .. '/' .. filter), '.lua')
      files = concat(files, found)
    end
  end

  table.sort(files, function(a, b) return a:upper() < b:upper() end)
  local reqs = {}
  for index, path in ipairs(files) do
    path = fs2reqPath(path, rootPath)
    reqs[path] = index
    reqs[index] = path
  end
  return files, reqs
end


return projParser
