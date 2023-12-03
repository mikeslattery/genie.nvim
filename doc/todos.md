# List of Possible Features

## Misc Ideas


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

## Wish commands

These have been tried and appear to work.
Btw, just because these worked for me, doesn't mean they'll always work in the future.

```vim
" Arbitrary questions simply return a GPT-4 answer
:Wish Close all windows except current one
:Wish Close all buffers except current one
:Wish Close all *.lua buffers
:Wish Get length of longest line in current buffer. Set current window width to that length plus 9.
:Wish Create vertical split and make it current window. Edit README.md in prior buffer.
:Wish What is our our current location?  You can use `curl` to determine.
:Wish How tall is Mount Everest?
:Wish Send keys 'echo hello' to the tmux pane to the right of current one. Do not use plenary.
```

## Untested Wish Commands

```vim
:Wish install vim-fugative plugin using vim-plug.  Modify plugin list in ~/.config/nvim/init.lua
:Wish What is the most popular neovim plugin on github?  You can use plenary's curl().  Plenary plugin and `c url` are both installed.
```

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

## Issues

* Sometimes code is inside markdown block.
