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
  if rootPath == "" then
    return fullPath
  end
  local cleanrootPath = rootPath
  cleanrootPath = cleanrootPath:gsub("\\\\", "/")
  cleanrootPath = cleanrootPath:gsub("\\", "/")
  fullPath = fullPath:gsub(cleanrootPath.."/", "")
  fullPath = fullPath:gsub(cleanrootPath, "")
  return fullPath
end


--[[ Create unique name for .md file
> file (string) full path to .lua file
> rootPath (string) full path to the project root
< outFilename (string)
]]
function writer.makeOutputFileName(file, rootPath)
  local outFilename = file..".md"
  outFilename = writer.stripOutRoot(outFilename, rootPath)
  outFilename = outFilename
    :gsub("/", ".")
    :gsub(".lua", "")
    :gsub(".init.", ".")
  return outFilename
end


return writer
