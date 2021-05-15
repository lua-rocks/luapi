--[[ writer ]]--


local writer = {}


function writer.open(filename)
  local file = io.open(filename, "w+")
  if not file then
    print("error: failed to create '"..filename.."'")
    return
  end
  return file
end


function writer.stripOutRoot(text, rootPath)
  if rootPath == "" then
    return text
  end
  local cleanrootPath = rootPath
  cleanrootPath = cleanrootPath:gsub("\\\\", "/")
  cleanrootPath = cleanrootPath:gsub("\\", "/")
  text = text:gsub(cleanrootPath.."/", "")
  text = text:gsub(cleanrootPath, "")
  return text
end


function writer.makeOutputFileName(file, config, rootPath)
  local outFilename = file..config.outputType
  outFilename = writer.stripOutRoot(outFilename, rootPath)
  outFilename = outFilename:gsub("/", ".")
  outFilename = outFilename:gsub(config.codeSourceType, "")
  return outFilename
end


return writer
