## Introduction

Genie is a Neovim plugin that uses OpenAI's GPT-4 model to generate Lua code based on a given action. The generated code can be executed immediately in Neovim.

## Installation

To install the Genie plugin, use your preferred Neovim plugin manager. For example, if you are using vim-plug, add the following line to your `init.vim` file:

```vim
Plug 'mikeslattery/genie'
```

Then, run the following command in Neovim:

```vim
:PlugInstall
```

## Configuration

To configure the Genie plugin, you can use the `genie.config()` function in your `init.vim` file. Here is an example:

```lua
lua require('genie').config({model = 'gpt-4-1106-preview'})
```

The available configuration options are:

- `model`: The model to use for the OpenAI API. Default is 'gpt-4'.
- `temperature`: The temperature for the OpenAI API. Default is 0.
- `access_key`: The access key for the OpenAI API. Default is the value of the `OPENAI_API_KEY` environment variable.

## Usage

To use the Genie plugin, you can use the `:Wish` command followed by the action you want to perform. For example:

```vim
:Wish Open a new tab.
```

This will generate and execute the Lua code to open a new tab in Neovim.

## Commands

- `:Wish {action}`: Generate and execute the Lua code for the given action.

## Functions

- `genie.config({config})`: Set the configuration for the Genie plugin.
- `genie.ai(prompt)`: Get the response from the OpenAI API for the given prompt.
- `genie.generate_code(action)`: Generate the Lua code for the given action.
- `genie.wish(action)`: Generate and execute the Lua code for the given action.
