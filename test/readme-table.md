# Öbject - Base superclass that implements Ö𑫁𐊯

Key features of this library:

- Metamethods inheritance
- Store all metadata in metatables (no `__junk` in actual tables)
- Can subtly identify class membership
- Very tiny and fast, readable source

| Fields | |
| --- | --- |
| **Öbject : [table][]** | No requirements |
| **Öbject.classname : [string][] = "Öbject"** | Name of the class |
| **Öbject.super : Öbject \| {} = {}** | Parent class |

| Methods | |
| --- | --- |
| **Öbject:new (...\*) : Öbject** | Creates an instance of the class |
| **Öbject:init (fields)** | Initializes the class |
| **Öbject:extend (name\*, ...) : Öbject** | Creates a new class by inheritance |
| **Öbject:implement (...\*)** | Sets someone else's methods |
| **Öbject:has (Test\*, limit) : integer \| boolean** | Returns the range of kinship between itself and the checking class |
| **Öbject:is (Test\*) : boolean** | Identifies affiliation to class |
| **Öbject:each (etype\*, action\*, ...) : {integer=table}** | Loops through all elements, performing an action on each |

| Internals | |
| --- | --- |
| **applyMetaFromParents (self\*, apply_here\*)** | Adds all metamethods from itself and all parents to the specified table |
| **applyMetaIndexFromParents (self\*, apply_here\*)** | Adds __index metamethods from itself or closest parent to the table |

[string]: https://www.lua.org/manual/5.1/manual.html#5.4
[table]: https://www.lua.org/manual/5.1/manual.html#5.5
