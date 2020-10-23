# lua-scriptum

## Vignette

**Title**:
lua-scriptum

**Version**:
0.1

**Description**:
Document generator for Lua based code;
The output files are in markdown syntax.

**!Warning!** This is currently a test module that has a dependancy to Love2D.
Check back later, I will remove this and make ready for common use.

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
Create an optional header vignette with a comment block.
Start from the first line of the source file, and use these tags (all optional):

- **@title** the name of the file/module (once, single line)
- **@version** the current version (once, single line)
- **@description** module description (once, multiple lines)
- **@authors** the authors (once, single line)
- **@copyright** the copyright line (once, single line)
- **@license** the license (once, single line)
- **@sample** provide sample outputs (multiple entries, multiple lines)
- **@example** provide usage examples (multiple entries, multiple lines)

Such as the following:

    --[[
    @title Test Module
    @version 1.0
    @authors Mr. Munki
    @example Import and run with start()
    `local module = require("testmodule")
    `module.start()
    ]]

Backtic is used to mark a line as a code block when written in markdown.
Empty lines can be used if required as to your preference.


**Example**:
Create an API function entry with a comment block and one of more of:

    @param name (typing) <default> [note]
and
    @return name (typing) [note]

Such as:

    --[[My function for documentation
    @param name (typing) <required> [File will be created and overwritten]
    @param verbose (boolean) <default: true> [More output if true]
    @return success (boolean) [Fail will be handled gracefully and return false]
    ]]
    function module.startModule(name, verbose)
      local success = false
      -- sample code --
      return success
    end

Where:

- **name** is the parameter or return value
- optional **(typing)** such as (boolean), (number), (function), (string)
- optional **\<default\>** is the default value; if optional put \<nil\>; or \<required\> if so
- optional **[note]** is any further information


**Example**:
The markup used in this file requres escape symbols to generate the outputs properly:
- Where **()** with **start** or **end** can be used to escape block comments open and close.
- Angled brackets are escaped with \\< and \\>

## API

**start** (rootPath\*, outputPath\*) :   

> Start document generation  
> &rarr; **rootPath** (string) <*default: ""*> `Path to read source code from`  
> &rarr; **outputPath** (string) <*default: "scriptum"*> `Path to output to`  
