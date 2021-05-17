# FileParser



## API

**trim**
> Remove spaces or other chars from the beginning and the end of string  
>

**searchForPattern** (lines\*, startLine\*, forLines\*, pattern\*) : line, result  

> Search for first pattern in multiply lines.  
>
> &rarr; **lines** ({integer=string}) `list of lines`  
> &rarr; **startLine** (integer) `all lines before will be ignored`  
> &rarr; **forLines** (integer) `all lines after will be ignored`  
> &rarr; **pattern** (string) `search for this`  
>
> &larr; **line** (integer) *[optional]* `line number where pattern was found`  
> &larr; **result** (string) *[optional]* `matched result`  

**catchMultilineEnd** (set\*, multilines\*, multilineStarted\*)  
> &rarr; **set** (table)  
> &rarr; **multilines** (table)  
> &rarr; **multilineStarted** ("description")  

**multiLineField** (set\*, field\*, data\*)  
> &rarr; **set** (table)  
> &rarr; **field** ("description")  
> &rarr; **data** (string) `module name`  

**searchForTitle** (set\*, line\*, multilines\*, multilineStarted\*) : found  
> &rarr; **set** (table)  
> &rarr; **line** (string)  
> &rarr; **multilines** (table)  
> &rarr; **multilineStarted** (boolean)  
>
> &larr; **found** ("description"|nil)  

**extractHeaderBlock** (lines\*, startLine\*, data\*)  
> &rarr; **lines** (table)  
> &rarr; **startLine** `0`  
> &rarr; **data** (table)  

**readFileLines** (file\*)  
> &rarr; **file** (string) `full path to lua file`  

**correctOpt** (opt\*) : opt  
> &rarr; **opt** (string)  
>
> &larr; **opt** (string)  

**extractRequires** (lines\*, startLine\*, data\*)  
> &rarr; **lines** (table)  
> &rarr; **startLine** (integer)  
> &rarr; **data** (table)  

**extractFunctionComments** (fnSet\*, lines\*, startLine\*, j\*, which\*)  
> &rarr; **fnSet** (table)  
> &rarr; **lines** (table)  
> &rarr; **startLine** (integer)  
> &rarr; **j** (integer)  
> &rarr; **which** ("pars"|"returns")  

**extractUnpack** (fnSet\*, lines\*, startLine\*, j\*)  
> &rarr; **fnSet** (table)  
> &rarr; **lines** (table)  
> &rarr; **startLine** (integer)  
> &rarr; **j** (integer)  

**extractFunctionBlock** (lines\*, startLine\*, data\*)  
> &rarr; **lines** (table)  
> &rarr; **startLine** (integer)  
> &rarr; **data** (table)  

**fileParser.parse** (file\*) : data  
> &rarr; **file** (string) `path to file`  
>
> &larr; **data** ({"file"=string,"requires"=table,"api"=table})  

## Project

+ [Back to root](README.md)
