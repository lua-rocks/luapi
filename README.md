# LUAPI (WIP)

**LUAPI** is an attempt to bring together the best features of all lua
documentation tools I know, such as: [ldoc][], [luadoc][], [emmylua][] and
[scriptum][].

In my work I try to adhere to the [KISS][] principle, so that documenting your
code and modifying the source code for this utility should not cause
difficulties for anyone (but knowledge of the lua pattern matchers is still
required if you want to modify parser).

This repository was originally forked from `scriptum`, but I rewrote it
completely, so now there is little in common between `scriptum` and `luapi`.

## Similarities and differences

- Just like `scriptum`, `luapi` generates markdown documentation that you can
  easily convert to any other format, styling it as you like, or post on
  github/bitbucket etc, or just view it through a browser using the .md file
  viewer extension. Even in notepad, this documentation is quite readable.
- Unlike `scriptum`, `luapi` keeps all file in one string when parsing it and
  search patterns in this string or its chunks, but not loops through each
  line and it also writes each file only once so it should be much faster.
- Unlike most analogs, you are not required to memorize a set of tags and
  complex rules for their use. My tool is extremely simple! It only uses 2
  single-character tags and 2 kinds of brackets:
  - `>`: function argument or table field
  - `<`: function return or describing table as class
  - `(parentheses)`: the type or parent class of the variable
  - `[square brackets]`: default value of the variable (makes it _optional_)
  - _Congratulations! You have learned all the luapi api!_
  - Quick example:
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
  supported yet, so it's too early to promise anything.
- Unlike `scriptum` and like `ldoc`, only **external** module fields and methods
  will be written to markdown, but internal tables and functions still parsed
  and can be used for smart hints in IDE or somewhere else.
- Like `ldoc`, if your tags mismatch with real params or if you started comment
  block but not commented some params, you will get warnings in the terminal.
- Keep in mind that my project is still very young and poorly tested, so bugs
  are common at this stage.

## Todo

- Swap full paths with req paths.
- File can have one external class and many internals (tables as classes).
  - We probably no need `module.classes` table?
- Escape whatever you want with `\` (partitially done).
- Update comments in sources.
- Document `do ... end` blocks as sections.
- Unpack (`@`).
  - I like the idea of `scriptum`:`unpack` but it is not implemented yet.
  - Unpack should work with params and returns in any scope.
    Like this: `> @conf` or `< @conf`.
- Lua files in `doc` folder automaticaly includes in md-files as examples.
- Suppport for OOP: inheritance.
- Add support for [atom-autocomplete][].
- Clean markdown: no [markdownlint][] warnings.
- Combine all modules into one file and remove debug garbage.
- Squash my crazy commits.
- Publish to luarocks.

## Style guide

These rules are _optional_, but highly recommended:

- Maximum line number is **80** characters.
- `One line` **title** comments must start with **uppercase** letter.
- `One line` **parameter** comments must start with a **lowercase**.
- `One line` (**any**) comments must **not** have a dot or semicolon at the end.
- `Muliline` (**any**) comments must **have** a dot or semicolon at the end.

Of course, I can correct everything automatically in docgen, but don't forget
that your source code is also a documentation!

[KISS]: https://en.wikipedia.org/wiki/KISS_principle
[ldoc]: https://stevedonovan.github.io/ldoc/manual/doc.md.html
[luadoc]: https://keplerproject.github.io/luadoc
[scriptum]: https://github.com/charlesmallah/lua-scriptum
[emmylua]: https://github.com/EmmyLua
[markdownlint]: https://github.com/DavidAnson/markdownlint
[atom-autocomplete]: https://github.com/dapetcu21/atom-autocomplete-lua
