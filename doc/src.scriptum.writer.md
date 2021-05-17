# Writer



## API

**writer.open** (filename\*) : file  

> Open a file to write  
>
> &rarr; **filename** (string) `full path to the file`  
>
> &larr; **file** (table) `io.open result`  

**writer.stripOutRoot** (fullPath\*, rootPath\*) : relativePath  

> Convert full path to relative  
>
> &rarr; **fullPath** (string)  
> &rarr; **rootPath** (string)  
>
> &larr; **relativePath** (string)  

**writer.makeOutputFileName** (file\*, rootPath\*) : outFilename  

> Create unique name for .md file  
>
> &rarr; **file** (string) `full path to .lua file`  
> &rarr; **rootPath** (string) `full path to the project root`  
>
> &larr; **outFilename** (string)  

## Project

+ [Back to root](README.md)
