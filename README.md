# LUAPI

**luapi** is an attempt to bring together the best features of all lua
documentation tools I know, such as [ldoc][], [luadoc][], [emmylua][] and
[scriptum][].

In my work I try to adhere to the [KISS][] principle, so that documenting your
code and modifying the source code for this utility does not cause difficulties
for anyone (but knowledge of lua patterns is still required).

This product was originally a fork of `scriptum`, but I rewrote it completely,
so now there is little in common between `scriptum` and `luapi`.

## Similarities and differences

- Just like `scriptum`, `luapi` generates markdown documentation that you can
  easily convert to any other format styling it as you like, or just view it
  through a browser using the .md file viewer extension. Even in notepad, this
  documentation is quite readable.
- Unlike most analogs, you are not required to memorize a set of tags and
  complex rules for their use. My tool is extremely simple, it only uses 3
  single-character tags and 2 kinds of brackets:
  - `>`: table field or function argument
  - `<`: function return or parent class of the table
  - `@`: unpacking table content (not yet implemented)
  - `(parentheses)`: the type or class of the variable
  - `[square brackets]`: default value of the variable
  - _So you have learned all the api!_
  - Example:
  ```lua
  --[[ Some function title
  Some function comment.
  Can be multiline.
  _Support_ **markdown**.
  > str (string) some string comment
  > num (number) [2] some number comment
  < con (string) result of concatenation
  ]]
  local function example(str, num)
    num = num or 2
    return str .. num
  end
  ```
- I don't have tags like `@author` or `@copyright` because you can markdown this
  information inside module comments, and those tags are just garbage.
- Like `emmylua`, I plan to implement smart hints for the `atom` editor. Perhaps
  the list of editors will expand, but at the moment even `atom` is not
  supported yet, so it's too early to promise anything here.
- Like `ldoc`, if your tags mismatch with real params or if you started comment
  block but not commented some fields, you will get warnings in the terminal.
- Keep in mind that my project is still very young and poorly tested, so bugs
  are common at this stage.

## Todo

- Unpack (`@`).
  - I like the idea of `scriptum`:`@unpack` but it is not implemented yet.
  - Unpack should work with params and returns in any scope.
    Like this: `> @conf` or `< @conf`.
- Returns list.
- Better requirements (`{reqpath = classname,...}`).
- Lua files in `doc` folder automaticaly includes in md-files as examples.
- Suppport for OOP: inheritance.
- Add support for
  [this Atom extension](https://github.com/dapetcu21/atom-autocomplete-lua).
- Clean markdown:
  no [markdownlint](https://github.com/DavidAnson/markdownlint) warnings.
- Combine all modules into one file and remove debug garbage.
- Publish to luarocks.

## Style guide

These rules are optional, but highly recommended:

- Maximum line number is **80** characters.
- `One line` **title** comments must start with **uppercase** letter.
- `One line` **parameter** comments must start with a **lowercase**.
- `One line` **any** comments must **not** have a dot or semicolon at the end.

[KISS]: https://en.wikipedia.org/wiki/KISS_principle
[ldoc]: https://stevedonovan.github.io/ldoc/manual/doc.md.html
[luadoc]: https://keplerproject.github.io/luadoc
[scriptum]: https://github.com/charlesmallah/lua-scriptum
[emmylua]: https://github.com/EmmyLua
