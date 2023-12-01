# List of Possible Features

## Misc Ideas

None.

## Cache Workflow

1. Wish made
1. If existing wish, and not marked as failure, skip to execution
1. Code gen to file in the cache directory.  Name is hash of text.
1. execution (with `luafile`)
1. On failure - see Retry Workflow below

## Retry workflow

1. New wish
1. Code gen to file in the cache directory
1. execution (with `luafile`)
1. Runtime error happens.  Error message is captured.
1. Old code and error given to AI to attempt to generate fixed version.
1. User edit.
1. Loop back to execution above, up to 3 times.
1. Give up with error message.  Inject failure comment into code.

## Prompt Improvements

* List of installed lazy.nvim plugins
* List of configuration files

## Preview

```vim
:Wish     <prompt> - If this is first time running this prompt, edit code
:WishEdit <prompt> - Always edit cached entry.
:WishDo   <prompt> - Run code without edit
```

## Misc Commands

```vim
:WishDel  <prompt> - Remove from cache
:WishAlias <alias> <prompt> - Create a single-word alias for a prompt
```

## Meta Reprogram Plugins

```vim
:WishAddPlugin <plugin> <prompt>  - Create a plugin
:WishModPlugin <plugin> <prompt>  - Modify an existing plugin
```
