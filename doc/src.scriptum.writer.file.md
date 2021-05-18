# File Writer



## Requires

+ scriptum.writer

## API

**writeVignette** (file\*, set\*)  

> Write module description  
>
> &rarr; **file** (userdata) `io.file`  
> &rarr; **set** ({integer=string}) `lines to write`  

**printFn** (file\*, v3\*)  
> &rarr; **file** (userdata) `io.file`  
> &rarr; **v3** (table) `document model`  

**printParamsOrReturns** (file\*, v3\*, which\*)  
> &rarr; **file** (userdata) `io.file`  
> &rarr; **v3** (table) `document model`  
> &rarr; **which** ("pars"|"returns")  

**printUnpack** (file\*, v3\*)  
> &rarr; **file** (userdata) `io.file`  
> &rarr; **v3** (table) `document model`  

**fileWriter.write** (rootPath\*, outPath\*, config\*, data\*)  
> &rarr; **rootPath** (string)  
> &rarr; **outPath** (string)  
> &rarr; **config** (table)  
> &rarr; **data** (table)  

## Project

+ [Back to root](README.md)
