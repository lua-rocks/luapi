# Scriptum fork (WIP)

I'm not sure if I can find a time and superpowers to do all these things,
can't promise anything but I'll try :)

## Roadmap

- [x] Separate code to submodules for easier maintain.
  - [ ] Document every function in each module.
- [x] Remove `love` (why do we need it if it's not required?).
- [ ] Custom markdown template:
  - [x] H1 - Title of the current module (can be only one H1 in document)
  - [ ] H3 - Module fields (described tables and functions)
  - [ ] You can make links across all you files or just in one local file
    **to it parts** in this way: `[link_name](#header_name_in_current_file)` or
    `[link_name](other_file#header_name)`. That's why fields must be a headers.
- [x] Custom comments style.
  - [x] Replace **\`** (for subpattern code) with **~**
    (because **`** is used for keywords).
  - [x] Remove **all** vignette tags - just use markdown in comments instead.
    First line in first comment is title; other lines for description.
  - [x] Any function param is **required** by default. If it has default value,
    then it is optional. Empty opt values (like this: `<>`) are acceptable.
  - [x] Replace `@param`, `@return` and `@unpack` tags with `>`, `<` and `@`.
    I no need any other tags!
- [ ] Show doc only for external module fields.
- [ ] Multiline comments for fields descriptions.
- [ ] Throw error when function argument name doesn't match with described.
- [ ] Throw error when described argument type doesn't match with accepted !?
- [ ] Suppport for OOP: inheritance.
- [ ] Easy links for headers.
- [ ] Add support for
    [this Atom extension](https://github.com/dapetcu21/atom-autocomplete-lua).
- [ ] Clean markdown:
    no [markdownlint](https://github.com/DavidAnson/markdownlint) warnings.

## Style guide

These rules are not currently enforced, but they should.

- Maximum line number is 80 characters.
- One line title comments must start with uppercase letter.
- One line parameter comments must start with a lowercase.
- One line any comments must **not** have a dot or semicolon at the end.
