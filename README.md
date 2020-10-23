# lua-scriptum

## Vignette

**Title**:
lua-scriptum

**Description**:
Document generator for Lua based code;
The output files are in markdown syntax

**Authors**:
Charles Mallah

**Copyright**:
(c) 2020 Charles Mallah

**License**:
MIT license (mit-license.org)

**Sample**:
Output is in markdown

    This document was created with this module

**Example**:
Generate all documentation from the root directory

    local scriptum = require("scriptum")
    scriptum.start()

## API

**start** (rootPath) : x1, x2  

> Start document generation  
> &rarr; **rootPath** (string) <*required*> `Path that will contain the generated documentation`  
> &larr; **x1** (boolean) `Testing for output`  
> &larr; **x2** (number)  
