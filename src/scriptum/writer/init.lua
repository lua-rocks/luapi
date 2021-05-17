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


--[[ Convert full path to relative
> fullPath (string)
> rootPath (string)
< relativePath (string)
]]
function writer.stripOutRoot(fullPath, rootPath)
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
function writer.fs2reqPath(path, rootPath)
  path = writer.stripOutRoot(path, rootPath)
  path = path
    :gsub("/", ".")
    :gsub(".lua", "")
    :gsub(".init", "")
  print(path)
  return path
end


return writer
