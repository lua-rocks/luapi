# Scriptum fork (WIP)

I'm not sure if I can find a time and superpowers to do all these things,
can't promise anything but I'll try :)

## Roadmap

- [ ] Separate code to submodules for easier maintain.
  - [ ] Document every function in each module.
- [x] Remove `love` (why do we need it if it's not required?).
- [ ] Remove all H1: `Vignette`, `API`, `Project` and replace them with:
  - H1 - Title of the current module (can be only one H1 in document)
  - H2 - Module fields (described tables and functions)
  - You can make links across all you files or just in one local file
    **to it parts** in this way: `[link_name](#header_name_in_current_file)` or
    `[link_name](other_file#header_name)`. That's why fields must be a headers.
- [ ] Replace 4 spaces code indents with **```lua** style to enable syntax.
- [ ] Show doc only for module fields (maybe its default behavior idk).
- [ ] Custom comments style.
  - [ ] Replace **`** (for subpattern code) with something else.
  - [ ] Remove useless tags (`copyrights`, `authors`, `version`, etc).
  - [ ] Combine `title` and `description`.
  - [ ] Combine `sample` and `example`.
- [ ] Suppport for OOP: inheritance.
- [ ] Easy links for headers.
- [ ] Add support for
    [this Atom extension](https://github.com/dapetcu21/atom-autocomplete-lua).
- [ ] Clean markdown: no
    [markdownlint](https://github.com/DavidAnson/markdownlint) warnings.
