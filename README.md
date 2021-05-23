# Scriptum fork (WIP)

I'm not sure if I can find a time and superpowers to do all these things,
can't promise anything but I'll try 🤡

Examples temporary removed and current version don't write any files because
I want to rewrite everything from scratch!

See target template example (hand made)
[here](https://github.com/lua-rocks/object).

## Roadmap

- [ ] Rewrite everything! Find and fix bugs; improve code quality.
  - [x] Separate code to submodules for easier maintain.
    - [ ] Document every function in each module.
  - [ ] Parser
    - [x] Store entire file in one string and use short regexps to this string
      instead of multiline search and complex extractions.
    - [ ] Tables and fields; external and internal.
    - [x] Show warning when function argument name doesn't match with described.
    - [ ] Show warning when function is not described.
  - [ ] Writer
    - [ ] [Custom markdown template](https://github.com/lua-rocks/object).
      - [ ] Multiline comments for all descriptions.
      - [ ] Table of contents.
      - [ ] Easy links for headers.
- [ ] Custom comments style.
  - [ ] Colon for type (parentheses for arguments if the type is function).
  - [x] Remove **all** vignette tags - just use markdown in comments instead.
    First line in first comment is title; other lines for description.
  - [x] Replace `@param`, `@return` and `@unpack` tags with `>`, `<` and `@`.
    I no need any other tags!
  - [ ] Unpack (`@`) should work with params and returns in any scope.
    Like this: `> @conf` or `< @conf`.
  - [x] Square brackets for default function params and nothing for comment.
  - [x] Any function param is required by default. You don't need to
    specify this explicitly! If it has default value, then it's optional.
    Values `[]`, `[nil]` and `[opt]` are synonims to `[optional]`.
- [x] Remove `love` (why do we need it if it's not required?).
- [ ] Suppport for OOP: inheritance.
- [ ] Add support for
    [this Atom extension](https://github.com/dapetcu21/atom-autocomplete-lua).
- [ ] Clean markdown:
    no [markdownlint](https://github.com/DavidAnson/markdownlint) warnings.

## Style guide

These rules are not currently enforced, but they should.

- Maximum line number is **80** characters.
- `One line` **title** comments must start with **uppercase** letter.
- `One line` **parameter** comments must start with a **lowercase**.
- `One line` **any** comments must **not** have a dot or semicolon at the end.
