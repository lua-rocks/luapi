# Öbject - Base superclass that implements Ö𑫁𐊯

Key features of this library:

- Metamethods inheritance
- Store all metadata in metatables (no `__junk` in actual tables)
- Can subtly identify class membership
- Very tiny and fast, readable source

## Contents

- _Fields_
  - **[Öbject][] : [table][]**
    - `No requirements`
  - **[Öbject.classname][] : [string][] = "Öbject"**
    - `Name of the class`
  - **[Öbject.super][] : [Öbject][] | {} = {}**
    - `Parent class`
- _Methods_
  - **[Öbject:new][] (...\*) : [Öbject][]**
    - `Creates an instance of the class`
  - **[Öbject:init][] (fields)**
    - `Initializes the class`
  - **[Öbject:extend][] (name\*, ...) : [Öbject][]**
    - `Creates a new class by inheritance`
  - **[Öbject:implement][] (...\*)**
    - `Sets someone else's methods`
  - **[Öbject:has][] (Test\*, limit) : integer | boolean**
    - `Returns the range of kinship between itself and the checking class`
  - **[Öbject:is][] (Test\*) : boolean**
    - `Identifies affiliation to class`
  - **[Öbject:each][] (etype\*, action\*, ...) : {integer=table}**
    - `Loops through all elements, performing an action on each`
- _Functions_
  - **[applyMetaFromParents][] (self\*, apply_here\*)**
    - `Adds all metamethods from itself and all parents to the specified table`
  - **[applyMetaIndexFromParents][] (self\*, apply_here\*)**
    - `Adds __index metamethods from itself or closest parent to the table`

## Fields

### Öbject

- type: **[table][]**
- requirements: **none**

### Öbject.classname

Name of the class

- type: **[table][]**
- default: `"Öbject"`

### Öbject.super

Parent class

- type: **[Öbject][] | {}**
- default: `{}`

## Methods

### Öbject:new

Creates an instance of the class

&rarr; `...` **any** *[optional]* `arguments passed to init`

&larr; `instance` : **[Öbject][]**

### Öbject:init

Initializes the class

> By default, an object takes a table with fields and applies them to itself,
> but descendants are expected to replace this method with another.

&rarr; `fields` : **[table][]** *[optional]* `new fields`

### Öbject:extend

Creates a new class by inheritance

&rarr; `name` : **[string][]** `new class name`

&rarr; `...` : **[table][]** _or_ **[Öbject][]** *[optional]* `additional properties`

&larr; `cls` : **[Öbject][]**

### Öbject:implement

Sets someone else's methods

&rarr; `...` : **[table][]** _or_ **[Öbject][]** `methods`

### Öbject:has

Returns the range of kinship between itself and the checking class

> Returns `0` if it belongs to it _or_` false` if there is no kinship.

&rarr; `Test` : **[string][]** _or_ **[Öbject][]** `test class`

&rarr; `limit` : **integer** *[optional]* `check depth (default unlimited)`

&larr; `kinship` : **integer** _or_ **boolean**

### Öbject:is

Identifies affiliation to class

&rarr; `Test` : **[string][]** _or_ **[Öbject][]**

&larr; `result` : **boolean**

### Öbject:each

Loops through all elements, performing an action on each

> Can stop at fields, metafields, methods, or all.
> Always skips basic fields and methods inherent from the Object class.

&rarr; `etype` : **"field"**_,_ **"method"**_,_ **"meta"** _or_ **"all"** `element type`

&rarr; `action` : **function(key,value,...):any** `action on each element`

&rarr; `...` *[optional]* `additional arguments for the action`

&larr; `result` : **{integer=table}** `results of all actions`

## Internals

### applyMetaFromParents

Adds all metamethods from itself and all parents to the specified table

> Maintains the order of the hierarchy: Rect > Point > Object.

&rarr; `self` : **[Öbject][]** `apply from`

&rarr; `apply_here` : **[table][]** `apply to`

### applyMetaIndexFromParents

Adds __index metamethods from itself or closest parent to the table

&rarr; `self` : **[Öbject][]** `apply from`

&rarr; `apply_here` : **[table][]** `apply to`

[string]: https://www.lua.org/manual/5.1/manual.html#5.4
[table]: https://www.lua.org/manual/5.1/manual.html#5.5

[Öbject]: #contents
[Öbject.classname]: #öbjectclassname
[Öbject.super]: #öbjectsuper

[Öbject:new]: #öbjectnew
[Öbject:init]: #öbjectinit
[Öbject:extend]: #öbjectextend
[Öbject:implement]: #öbjectimplement
[Öbject:has]: #öbjecthas
[Öbject:is]: #öbjectis
[Öbject:each]: #öbjecteach

[applyMetaFromParents]: #applymetafromparents
[applyMetaIndexFromParents]: #applymetaindexfromparents
