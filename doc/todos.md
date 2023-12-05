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

## Untested Wish Commands

```vim
:Wish install vim-fugative plugin using vim-plug.  Modify plugin list in ~/.config/nvim/init.lua
:Wish What is the most popular neovim plugin on github?  You can use plenary's curl().  Plenary plugin and `c url` are both installed.

" AI use within AI, because not all context is known at code-gen time.
" I told it that there's an ai(prompt) function it can use.
:Wish Save buffer in ./tests/ and use AI for filename based on buffer contents.

" Save your commands to your permanent config
" In my internal prompt, I told it how to edit ~/.config/nvim/
:Wish Map <leader>w in nvim config file for last :Wish command

" For ultimate meta-programming, it can modify its behavior.
" In my internal prompt, I tell it how to fetch, rewrite, and save its own code
:Wish Modify wish() to never cache
:Wish Change AI prompt used by wish() to include local IP address
:Wish Change AI prompt used by wish() to be aware of global text_to_speech(text) function.

" Session management
:Wish If exists, load Session.vim and shada.main from ./.nvim/
:Wish On VimLeave,FocusLost save Session.vim and main.shada to ./.nvim/
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
