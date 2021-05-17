# ProjectParser



## API

**scanDir** (folder\*, fileTree) : fileTree  

>  Recursively scan directory and return list with each file path.  
>
> &rarr; **folder** (string) `folder path`  
> &rarr; **fileTree** (table) *[{}]* `table to extend`  
>
> &larr; **fileTree** (table) `result table`  

**filterFiles** (fileTree\*, ext\*) : fileTree  

>  Select and return only those files whose extensions match.  
>
> &rarr; **fileTree** (table)  
> &rarr; **ext** (string)  
>
> &larr; **fileTree** (table)  

**projParser.getFiles** (path\*, ext\*) : files  

>  Get list of all parseable files in directory.  
>
> &rarr; **path** (string) `directory full path`  
> &rarr; **ext** (string) `file extension`  
>
> &larr; **files** (table) `list of file paths`  

## Project

+ [Back to root](README.md)
