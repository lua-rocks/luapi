# lua-scriptum.lua

## Vignette

**Title**:
lua-scriptum

**Version**:
1.0

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

    This document was created with this module, view the source file to see example input
    And see the raw readme.md for example output

**Example**:
Generate all documentation from the root directory

    local scriptum = require("scriptum")
    scriptum.start()

**Example**:
Create an optional header vignette with a comment block and these tags (all optional):

    @title" the name of the file/module `(once, single line)`
    @version" the current version `(once, single line)`
    @description" module description `(once, multiple lines)`
    @authors" the authors `(once, single line)`
    @copyright" the copyright line `(once, single line)`
    @license" the license `(once, single line)`
    @sample" provide sample outputs `(multiple entries, multiple lines)`
    @example" provide usage examples `(multiple entries, multiple lines)`

**Example**:
Create an API function entry with a comment block and these tags (all optional):

    @param" provide sample outputs `(multiple entries, multiple lines)`

A description in the first line and parameter or return lines should contain:
    name (typing) <default> [note]
such as:
    @param filename (string) <default: "profiler.log"> [File will be created and overwritten]

Return values can be included inside the comment block with:
    @return" provide usage examples `(multiple entries, multiple lines)`
    name (typing) [note]
such as:
    @return success (boolean) [Fail will be handled gracefully and return false]

## API

**start** (rootPath) : x1, x2  

> Start document generation  
> &rarr; **rootPath** (string) <*required*> `Path that will contain the generated documentation`  
> &larr; **x1** (boolean) `Testing for output`  
> &larr; **x2** (number)  
