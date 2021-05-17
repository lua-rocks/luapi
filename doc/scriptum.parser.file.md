# FileParser



## API

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

**extractFunctionComments** (which\*)  
> &rarr; **which** ("pars"|"returns")  

**fileParser.parse** (file\*) : data  
> &rarr; **file** (string) `path to file`  
>
> &larr; **data** ({"file"=string,"requires"=table,"api"=table})  

## Project

+ [Back to root](README.md)
