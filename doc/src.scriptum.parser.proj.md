# Project Parser


## API

**stripOutRoot** (fullPath\*, rootPath\*) : relativePath

> Convert full path to relative
>
> &rarr; **fullPath** (string)<br/>
> &rarr; **rootPath** (string)<br/>
>
> &larr; **relativePath** (string)<br/>

**fs2reqPath** (path\*, rootPath\*) : path

> Convert filesystem path to require path
>
> &rarr; **path** (string) `full path to .lua file`<br/>
> &rarr; **rootPath** (string) `full path to the project root`<br/>
>
> &larr; **path** (string)<br/>

**scanDir** (folder\*, fileTree) : fileTree

> Recursively scan directory and return list with each file path.
>
> &rarr; **folder** (string) `folder path`<br/>
> &rarr; **fileTree** (table) *[{}]* `table to extend`<br/>
>
> &larr; **fileTree** (table) `result table`<br/>

**filterFiles** (fileTree\*, ext\*) : fileTree

> Select and return only those files whose extensions match.
>
> &rarr; **fileTree** (table)<br/>
> &rarr; **ext** (string)<br/>
>
> &larr; **fileTree** (table)<br/>

**concat** (...\*) : result

> Returns a new list consisting of all the given lists concatenated into one.
>
> &rarr; **...** ({integer=any}) `lists`<br/>
>
> &larr; **result** ({integer=any}) `concatenated list`<br/>

**projParser.getFiles** (rootPath\*, pathFilters) : files, reqs

> Get list of all parseable files in directory.
>
> &rarr; **rootPath** (string) `root directory full path`<br/>
> &rarr; **pathFilters** (table) *[optional]* `search files only in these subdirs`<br/>
>
> &larr; **files** ({integer=string}) `list of fs-file paths`<br/>
> &larr; **reqs** (table) `list of req-file paths`<br/>

## Project

+ [Back to root](README.md)
