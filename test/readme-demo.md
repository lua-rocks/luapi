# Öbject - Base superclass that implements Ö𑫁𐊯

Key features of this library:

- Metamethods inheritance
- Store all metadata in metatables (no `__junk` in actual tables)
- Can subtly identify class membership
- Very tiny and fast, readable source

## Contents

<details>
  <summary>Fields</summary>

  - [Öbject.classname](#Öbject-classname) : **[string][]**
    - Name of the class
  - [Öbject.super](#Öbject-super) : **Öbject** _or_ **{}**
    - Parent class  

</details>
<details>
  <summary>Methods</summary>

  - [Öbject:new _or_ Öbject](#Öbject-new) (_..._)
    - Creates an instance of the class
  - [Öbject:init](#Öbject-init) (_fields_)
    - Initializes the class
  - [Öbject:extend](#Öbject-extend) (**name**\*, _..._) : **Öbject**
    - Creates a new class by inheritance
  - [Öbject:implement](#Öbject-implement) (**...**\*)
    - Sets someone else's methods
  - [Öbject:has](#Öbject-has) (**Test**\*, _limit_) : **integer** _or_ **boolean**
    - Returns the range of kinship between itself and the checking class
  - [Öbject:is](#Öbject-is) (**Test**\*) : **boolean**
    - Identifies affiliation to class
  - [Öbject:each](#Öbject-each) (**etype**\*, **action**\*, _..._) : **[table][]**
    - Loops through all elements, performing an action on each

</details>
<details>
  <summary>Internals</summary>

  - [applyMetaFromParents](#applyMetaFromParents) (**self**\*, **apply_here**\*)
    - Adds all metamethods from itself and all parents to the specified table
  - [applyMetaIndexFromParents](#applyMetaIndexFromParents) (**self**\*, **apply_here**\*)
    - Adds __index metamethods from itself or closest parent to the table

</details>
<details>
  <summary>Example</summary>

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

## Fields

<a name="Öbject-classname" href="#contents">Öbject.classname</a>

Name of the class  

type: **[string][]**  
default: `"Öbject"`  

---

<a name="Öbject-super" href="#contents">Öbject.super</a>

Parent class  

type: **Öbject** _or_ **{}**  
default: `{}`  

## Methods

<a name="Öbject-new" href="#contents">Öbject:new</a>
(_..._)

Creates an instance of the class  

&rarr; `...` **any** *[optional]* `arguments passed to init`

&larr; `instance` : **Öbject**

---

<a name="Öbject-init" href="#contents">Öbject:init</a>
(_fields_)

Initializes the class  

> By default, an object takes a table with fields and applies them to itself,  
> but descendants are expected to replace this method with another.  

&rarr; `fields` : **[table][]** *[optional]* `new fields`

---

<a name="Öbject-extend" href="#contents">Öbject:extend</a>
(**name**\*, ...) : **Öbject**

Creates a new class by inheritance  

&rarr; `name` : **[string][]** `new class name`  
&rarr; `...` : **[table][]** _or_ **Öbject** *[optional]* `additional properties`  

&larr; `cls` : **Öbject**

---

<a name="Öbject-implement" href="#contents">Öbject:implement</a>
(**...**\*)

Sets someone else's methods  

&rarr; `...` : **[table][]** _or_ **Öbject** `methods`

---

<a name="Öbject-has" href="#contents">Öbject:has</a>
(**Test**\*, _limit_) : **integer** _or_ **boolean**

Returns the range of kinship between itself and the checking class  

> Returns `0` if it belongs to it _or_` false` if there is no kinship.  

&rarr; `Test` : **[string][]** _or_ **Öbject** `test class`  
&rarr; `limit` : **integer** *[optional]* `check depth (default unlimited)`  

&larr; `kinship` : **integer** _or_ **boolean**

---

<a name="Öbject-is" href="#contents">Öbject:is</a>
(**Test**\*) : **integer** _or_ **boolean**

Identifies affiliation to class  

&rarr; `Test` : **[string][]** _or_ **Öbject**

&larr; `result` : **boolean**

---

<a name="Öbject-each" href="#contents">Öbject:each</a>
(**etype**\*, **action**\*, _..._) : **boolean**

Loops through all elements, performing an action on each  

> Can stop at fields, metafields, methods, or all.  
> Always skips basic fields and methods inherent from the Object class.  

&rarr; `etype` : **"field"**_,_ **"method"**_,_ **"meta"** _or_ **"all"** `element type`  
&rarr; `action` : **function(key,value,...):any** `action on each element`  
&rarr; `...` *[optional]* `additional arguments for the action`  

&larr; `result` : **{integer=table}** `results of all actions`

## Internals

<a name="applyMetaFromParents" href="#contents">applyMetaFromParents</a>
(**self**\*, **apply_here**\*)

Adds all metamethods from itself and all parents to the specified table  

> Maintains the order of the hierarchy: Rect > Point > Object.  

&rarr; `self` : **Öbject** `apply from`  
&rarr; `apply_here` : **[table][]** `apply to`  

---

<a name="applyMetaIndexFromParents" href="#contents">applyMetaIndexFromParents</a>
(**self**\*, **apply_here**\*)

Adds __index metamethods from itself or closest parent to the table  

&rarr; `self` : **Öbject** `apply from`  
&rarr; `apply_here` : **[table][]** `apply to`  

[string]: https://www.lua.org/manual/5.1/manual.html#5.4
[table]: https://www.lua.org/manual/5.1/manual.html#5.5
