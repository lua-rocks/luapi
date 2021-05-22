--[[ Project Parser ]]--


local projParser = {}


--[[ Convert filesystem path to require path
> path (string) full path to .lua file
> rootPath (string) full path to the project root
< path (string)
]]
local function fs2reqPath(path, rootPath)
  rootPath = rootPath
    :gsub("\\\\", "/")
    :gsub("\\", "/")
  path = path
    :gsub(rootPath.."/", "")
    :gsub(rootPath, "")
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
  if not fileTree then fileTree = {} end
  local ostype = package.config:sub(1, 1)
  if ostype == "\\" or ostype == "\\\\" then ostype "windows"
  else ostype = "linux" end
  folder = folder:gsub("\\\\", "/"):gsub("\\", "/")

  -- Files --
  local file
  local command
  if ostype == "windows" then
    command = 'dir "'..folder..'" /b /a-d-h'
  else
    command = 'ls -p "'..folder..'" | grep -v /'
  end
  file = io.popen(command)
  for item in file:lines() do
    item = (folder.."/"..item):gsub("//", "/")
    table.insert(fileTree, item)
  end
  file:close()

  -- Folders --
  if ostype == "windows" then
    command = 'dir "'..folder..'" /b /ad-h'
  else
    command = 'ls -p "'..folder..'" | grep /'
  end
  file = io.popen(command)
  for item in file:lines() do
    item = item:gsub("\\", "")
    fileTree = scanDir(folder.."/"..item, fileTree)
  end
  file:close()

  return fileTree
end


--[[ Select and return only those files whose extensions are '.lua'.
> fileTree (table)
< fileTree (table)
]]
local function filterFiles(fileTree)
  local set = {}
  for _, path in ipairs(fileTree) do
    if path:find('%.lua$') then table.insert(set, path) end
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
    files = filterFiles(scanDir(rootPath))
  else
    for _, filter in ipairs(pathFilters) do
      local found = filterFiles(scanDir(rootPath .. '/' .. filter))
      files = concat(files, found)
    end
  end

  table.sort(files, function(a, b) return a:upper() < b:upper() end)
  local reqs = {}
  for index, path in ipairs(files) do
    path = fs2reqPath(path, rootPath)
    -- FIXME
    reqs[path] = index
    reqs[index] = path
  end
  return files, reqs
end


return projParser
