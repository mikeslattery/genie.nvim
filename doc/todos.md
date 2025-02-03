# List of Possible Features

## Misc Ideas

* Fix to support visual mode selections
* Output to `~/.config/nvim/wishes` as a module
* Generate unit tests

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
1. Loop back to execution above, up to 2 more times.
1. Give up with error message.  Inject failure comment into code.
1. Load file into editor with error message near top.

## Prompt Improvements

* List of installed lazy.nvim plugins
* List of configuration files
* Recommended filename in output

## Recommended mappings

* Search for past `Wish` commands
* Search for generated wish files

## Tested Wish commands not yet in docs

```vim
:Wish Using autocmds, start a timer when I go into insert mode, and when I exit insert mode then echo how many WPM it was.
:Wish the visual mode selected text content is an AI prompt.  Directly after the range, insert the AI response.
```


## Untested Wish Commands

```vim
:Wish install vim-fugative plugin using vim-plug.  Modify plugin list in ~/.config/nvim/init.lua
:Wish What is the most popular neovim plugin on github?  You can use plenary's curl() and you can ask GPT questions.  Plenary plugin and `curl` are both installed.

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

On VimLeave,FocusLost save Session.vim and main.shada to `./.nvim/`.
Create the directory if it doesn't exist.
```

## Preview

```vim
:Wish     <prompt> " If this is first time running this prompt, edit code
:WishEdit <prompt> " Always edit cached entry.
:WishDo   <prompt> " Run code without edit
```

First line of scripts look like this:

```lua
-- To run-> :so %
-- To delete-> :bd!|!rm #
-- To load into config -> :bd|!mv # ~/.config/nvim/plugins/.
```

## Fixes and Failures

```vim
:WishFailed [<prompt>] " Signal that wish didn't work.
```

This differs from a runtime error.  This means that the desired behavior didn't work.
Possible responses:

* Inject comments into wish, signifying this
* Ask questions, perhaps to clarify
* Generate a unit test.  The user would edit of course.

## Misc Commands

```vim
:WishDel  <prompt> " Remove from cache
:WishAlias <alias> <prompt> " Create a single-word alias for a prompt
```

Perhaps in the generated code, there could be a comment with a suggested alias.

## Meta Reprogram Plugins

```vim
:WishAddPlugin <plugin> <prompt> " Create a plugin
:WishModPlugin <plugin> <prompt> " Modify an existing plugin
```

## Learn API and Plugins

* In build, ask AI what API functions it is not aware of, and keep that as a list.
* AI may ask for more information about functions.
* May require "Code Interpreter" type of processing.  Analyze/research before making a plan.
* Give it a summary of plugins you have installed and their API
* Give it a summary of popular available plugins that it may install if needed to achieve task.

## Issues

* Sometimes code is inside markdown block.

----

## Ultimate AI tool

Combined utility of `mdfile aifix aido aitestgen aitodos`

1. story.  TODO: write feature, and scenarios.  Put TODO into first scenario
1. scenario.  TODO: write test

Abilities

* Gen file, gen diff
* run read-only shell command
* Run test

* todo comment planning
  * Gather list of files.  Inject into prompt
  * Scan project for to-dos
  * Process each file with a TODO
  * what other files it will need to load?
  * priorities
    * FIXME - means a test failure
    * TODO in
* "what's next planning?"
  * Look's at state of project, current ticket, and current task to determine what to do next
  * Priorities
    * TODO comments

## Code TODO Snippets

```lua
-- lua/ax/init.lua

-- TODO: get rid of redirs
-- TODO: automate test generation

-- M.setup()
-- FIXME: args
```

```lua
-- Function to return name of the package manager that's been installed.
local function get_package_manager()
    if vim.fn.exists('g:plugged') == 1 then
        return 'vim-plug'
    elseif vim.fn.exists('g:dein#install#_installed') == 1 then
        return 'dein.vim'
    elseif vim.fn.exists('g:packer_plugins') == 1 then
        return 'packer.nvim'
    elseif vim.fn.exists('g:lazy#loaded') == 1 then
        return 'lazy.nvim'
    elseif vim.fn.exists('g:mini#deps#loaded') == 1 then
        return 'mini.deps'
    else
        return 'unknown'
    end
end



```

I am creating an AI LLM prompt to generate some Neovim Lua plugins.
For context I am including editor version, OS name, value of $TERM, and list of installed plugins.
What else could I add to the context?
To create a comprehensive context for generating Neovim Lua plugins using an AI language model, you can include additional details that will help the model understand your environment and requirements better. Here are some suggestions:

1. **Neovim Configuration Details**:
   - Current Neovim configuration files (init.lua or init.vim).
   - Specific settings or options you have customized.

2. **Programming Languages and Frameworks**:
   - List of programming languages you frequently use.
   - Any specific frameworks or libraries you work with.

3. **Desired Plugin Functionality**:
   - Specific features or functionalities you want the plugin to have.
   - Examples of existing plugins that you like or want to emulate.

4. **User Preferences**:
   - Keybindings or shortcuts you prefer.
   - UI/UX preferences (e.g., minimalistic, feature-rich, etc.).

5. **Performance Considerations**:
   - Any performance constraints or optimizations you need.
   - Resource limitations (e.g., memory, CPU).

6. **Development Environment**:
   - Version of Lua you are using.
   - Any specific Lua libraries or modules you rely on.

7. **Plugin Management**:
   - Plugin manager you are using (e.g., Packer, Vim-Plug).
   - How you prefer to manage plugin dependencies.

8. **Debugging and Testing**:
   - Tools or methods you use for debugging and testing Neovim plugins.
   - Any specific testing frameworks or practices you follow.

9. **Community and Collaboration**:
   - Whether you plan to share the plugin with the community.
   - Any collaboration tools or platforms you use (e.g., GitHub, GitLab).

10. **Documentation and Support**:
    - How you prefer to document your plugins.
    - Any support or maintenance plans you have in mind.

By providing these additional details, you can give the AI a more complete picture of your environment and needs, which will help it generate more relevant and useful Neovim Lua plugins.


----

File: `.editorconfig`

```editorconfig
# editorconfig.org
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
max_line_length = 100

[*.{txt,md}]
max_line_length = off
indent_size = unset
max_line_length = unset

[Makefile]
max_line_length = off
indent_style = tab

```

Generate a `.gitattribute` file that matches the above `.editorconfig` file.
Sure, here is a `.gitattributes` file that matches the settings specified in your `.editorconfig` file:

```gitattributes
# Apply settings to all files
* text=auto eol=lf

# Ensure UTF-8 encoding for all files
* text working-tree-encoding=UTF-8

# Trim trailing whitespace and ensure final newline for all files
* whitespace=fix
