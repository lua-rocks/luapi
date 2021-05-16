--[[ writer ]]--


local writer = {}


--[[ Open a file to write
@param filename (string) [full path to the file]
@return file (table) [io.open result]
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
@param fullPath (string)
@param rootPath (string)
@return relativePath (string)
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



function writer.makeOutputFileName(file, config, rootPath)
  print(file, config, rootPath)
  local outFilename = file..config.outputType
  outFilename = writer.stripOutRoot(outFilename, rootPath)
  outFilename = outFilename:gsub("/", ".")
  outFilename = outFilename:gsub(config.codeSourceType, "")
  print(outFilename)
  return outFilename
end


return writer
