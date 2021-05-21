# File Writer --


## Requires

+ scriptum.writer

## API

**writeVignette** (file\*, set\*)

> Write module description
>
> &rarr; **file** (userdata) `io.file`<br/>
> &rarr; **set** ({integer=string}) `lines to write`<br/>

**printFn** (file\*, v3\*)
> &rarr; **file** (userdata) `io.file`<br/>
> &rarr; **v3** (table) `document model`<br/>

**printParamsOrReturns** (file\*, v3\*, which\*)
> &rarr; **file** (userdata) `io.file`<br/>
> &rarr; **v3** (table) `document model`<br/>
> &rarr; **which** ("pars"|"returns")<br/>

**printUnpack** (file\*, v3\*)
> &rarr; **file** (userdata) `io.file`<br/>
> &rarr; **v3** (table) `document model`<br/>

**fileWriter.write** (rootPath\*, outPath\*, config\*, data\*)
> &rarr; **rootPath** (string)<br/>
> &rarr; **outPath** (string)<br/>
> &rarr; **config** (table)<br/>
> &rarr; **data** (table)<br/>

## Project

+ [Back to root](README.md)
