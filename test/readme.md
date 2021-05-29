# Öbject - Base superclass that implements Ö𑫁𐊯

Key features of this library:

- Metamethods inheritance
- Store all metadata in metatables (no `__junk` in actual tables)
- Can subtly identify class membership
- Very tiny and fast, readable source

<details><summary><b>Example</b></summary>

```lua
local Object = require 'object'

local Point = Object:extend 'Point'

Point.scale = 2 -- Class field!

function Point:init(x, y)
  self.x = x or 0
  self.y = y or 0
end

function Point:resize()
  self.x = self.x * self.scale
  self.y = self.y * self.scale
end

function Point.__call()
  return 'called'
end

local Rectangle = Point:extend 'Rectangle'

function Rectangle:resize()
  Rectangle.super.resize(self) -- Extend Point's `resize()`.
  self.w = self.w * self.scale
  self.h = self.h * self.scale
end

function Rectangle:init(x, y, w, h)
  Rectangle.super.init(self, x, y) -- Initialize Point first!
  self.w = w or 0
  self.h = h or 0
end

function Rectangle:__index(key)
  if key == 'width' then return self.w end
  if key == 'height' then return self.h end
end

function Rectangle:__newindex(key, value)
  if key == 'width' then self.w = value
    elseif key == 'height' then self.h = value
  end
end

local rect = Rectangle:new(2, 4, 6, 8)

assert(rect.w == 6)
assert(rect:is(Rectangle))
assert(rect:is('Rectangle'))
assert(not rect:is(Point))
assert(rect:has('Point') == 1)
assert(Rectangle:has(Object) == 2)
assert(rect() == 'called')

rect.width = 666
assert(rect.w == 666)
assert(rect.height == 8)

for _, t in ipairs({'field', 'method', 'meta'}) do
  rect:each(t, function(k, v) print(t, k, v) end)
end
```

</details>

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

### Öbject

Extends: **[table][]**

Requires: **none**

&rarr; `classname` **[string][]** *["Object"]* `name of the class`

&rarr; `super` **[Öbject][]** or **{}** *[{}]* `parent class`

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

[string]: https://www.lua.org/manual/5.1/manual.html#5.4
[table]: https://www.lua.org/manual/5.1/manual.html#5.5

[this module]: #contents

[Öbject]: #öbject
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
