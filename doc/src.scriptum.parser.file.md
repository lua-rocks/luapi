# File Parser


## API

**trim**
> Remove spaces or other chars from the beginning and the end of string
>

**searchForPattern** (lines\*, startLine\*, forLines\*, pattern\*) : line, result

> Search for first pattern in multiply lines.
>
> &rarr; **lines** ({integer=string}) `list of lines`<br/>
> &rarr; **startLine** (integer) `all lines before will be ignored`<br/>
> &rarr; **forLines** (integer) `all lines after will be ignored`<br/>
> &rarr; **pattern** (string) `search for this`<br/>
>
> &larr; **line** (integer) *[optional]* `line number where pattern was found`<br/>
> &larr; **result** (string) *[optional]* `matched result`<br/>

**catchMultilineEnd** (set\*, multilines\*)
> &rarr; **set** (table)<br/>
> &rarr; **multilines** (table)<br/>

**multiLineField** (set\*, data\*)
> &rarr; **set** (table)<br/>
> &rarr; **data** (string) `module name`<br/>

**searchForTitle** (set\*, line\*, multilines\*, multilineStarted\*) : found
> &rarr; **set** (table)<br/>
> &rarr; **line** (string)<br/>
> &rarr; **multilines** (table)<br/>
> &rarr; **multilineStarted** (boolean)<br/>
>
> &larr; **found** ("description"|nil)<br/>

**extractHeaderBlock** (lines\*, startLine\*, data\*)
> &rarr; **lines** (table)<br/>
> &rarr; **startLine** (integer) `0`<br/>
> &rarr; **data** (table)<br/>

**readFileLines** (file\*)
> &rarr; **file** (string) `full path to lua file`<br/>

**correctOpt** (opt\*) : opt
> &rarr; **opt** (string)<br/>
>
> &larr; **opt** (string)<br/>

**extractRequires** (lines\*, startLine\*, data\*)
> &rarr; **lines** (table)<br/>
> &rarr; **startLine** (integer)<br/>
> &rarr; **data** (table)<br/>

**extractFunctionComments** (fnSet\*, lines\*, startLine\*, j\*, which\*)
> &rarr; **fnSet** (table)<br/>
> &rarr; **lines** (table)<br/>
> &rarr; **startLine** (integer)<br/>
> &rarr; **j** (integer)<br/>
> &rarr; **which** ("pars"|"returns")<br/>

**extractUnpack** (fnSet\*, lines\*, startLine\*, j\*)
> &rarr; **fnSet** (table)<br/>
> &rarr; **lines** (table)<br/>
> &rarr; **startLine** (integer)<br/>
> &rarr; **j** (integer)<br/>

**extractFunctionBlock** (lines\*, startLine\*, data\*)
> &rarr; **lines** (table)<br/>
> &rarr; **startLine** (integer)<br/>
> &rarr; **data** (table)<br/>

**fileParser.parse** (file\*) : data
> &rarr; **file** (string) `path to file`<br/>
>
> &larr; **data** ({"file"=string,"requires"=table,"api"=table})<br/>

## Project

+ [Back to root](README.md)
