# List of Possible Features

## Ideas

* Inject into prompt a list of installed plugins
* Cache w/disable
* Retry with regeneration

## Preview

```vim
:Wish     <prompt> - If this is first time running this prompt, edit code
:WishEdit <prompt> - Edit cached response to prompt.
:WishDo   <prompt> - Run code without edit
```

## Misc Commands

```vim
:WishDel  <prompt>
:WishAlias <alias> <prompt> - Create a single-word alias for a prompt
```

## Meta Reprogram Plugins

```vim
:WishPlugin <plugin> <prompt>
```

# Fixes

## Makefile

```Makefile
@$(NVIM) \
--headless \
--noplugins -u "$(PLUGINS_DIR)/minimal.vim" \
```

