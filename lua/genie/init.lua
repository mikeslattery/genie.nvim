local M = {}

local PROMPT = [[INSTRUCTION:
Generate LUA CODE for Neovim to perform the ACTION to run with the `:luafile` command.
This code will run immediately, so do not generate functions or commands unless requested.
Do not require any plugins, except those listed below under PLUGINS.
Only generate the raw Lua code, without surrounding commentary or enclosing markdown code block.
Function `require('genie').ai(prompt_string)` can be called to ask GPT questions
and it returns a string.

CONTEXT: %s

ACTION:
Create new tab.

LUA CODE:
vim.cmd('tabnew')

ACTION:
%s

LUA CODE:
]]

local function generate_prompt(context, action)
  return string.format(PROMPT, context, action)
end

local function get_lazy_plugins()
    local status, lazy = pcall(require, 'lazy')
    if not status then
        return {}
    end
    local plugins = lazy.get_plugins()

    local plugin_names = {}
    for _, plugin in ipairs(plugins) do
        table.insert(plugin_names, plugin.name)
    end
    return plugin_names
end

local function get_plug_plugins()
  local plugins = vim.g.plugs or {}
  local plugin_list = {}
  for name, _ in pairs(plugins) do
    table.insert(plugin_list, name)
  end
  return plugin_list
end

local function get_packer_plugins()
    local status, packer = pcall(require, 'packer') -- Load the packer module safely
    if not status then
        return {} -- Return empty list if packer isn't installed
    end

    local packer_plugins = packer.plugin_names() -- Get the list of plugin names
    local plugin_list = {}

    for _, plugin_name in ipairs(packer_plugins) do
        table.insert(plugin_list, plugin_name)
    end

    return plugin_list
end

local function get_package_manager()
    if vim.g['plugs'] then
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


local function generate_context_string()
  local nvim_version = vim.version()
  local os_name = vim.loop.os_uname().sysname
  local term = os.getenv("TERM")

  -- get list of installed plugins
  local plugin_table = vim.tbl_extend('keep',
    get_plug_plugins(), get_lazy_plugins(), get_packer_plugins())
  local plugin_list = table.concat(plugin_table, '\n')

  local editor_version_string = string.format(
    "nvim v%s.%s.%s", nvim_version.major, nvim_version.minor, nvim_version.patch)

  local package_manager = get_package_manager()

  return string.format("EDITOR='%s', KERNEL='%s', TERM='%s'\nPackage manager = %s\n\nPLUGINS:\n%s",
    editor_version_string, os_name, term, package_manager, plugin_list)
end

local function get_config_from_env_file()
  local access_key = nil
  local base_url = nil
  local env_file = './.env'
  local file = io.open(env_file, "r")
  if file then
    for line in file:lines() do
      local key, value = line:match("([^=]+)=([^=]+)")
      if key == "OPENAI_API_KEY" then
        access_key = value
      end
      if key == "OPENAI_API_BASE" then
        base_url = value
      end
    end
    file:close()
  end
  return base_url, access_key
end

-- Configuration options, with defaults
local function init_config()
  base_url, access_key = get_config_from_env_file()
  local config = {
    model = 'gpt-4o',
    temperature = 0,
    base_url   = os.getenv('OPENAI_API_BASE') or base_url or 'https://api.openai.com/v1',
    access_key = os.getenv('OPENAI_API_KEY') or access_key
  }

  return config
end

local config = init_config()

-- write and read configuration.
function M.config(user_config)
  config = vim.tbl_deep_extend("force", config, user_config)
  return config
end

-- Send a prompt to OpenAI as a user message and return the assistant message.
function M.ai(prompt)
  local openai_api_key = config.access_key -- Use the access key from the configuration

  if not openai_api_key then
    error('The access key is not set in the configuration.')
  end

  -- Couldn't use plenary curl because it doesn't support timeout override.

  local data = vim.fn.json_encode({
    model = config.model, -- Use the model from the configuration
    temperature = config.temperature,
    messages = {
      {
        role = "user",
        content = prompt
      }
    }
  })

  local command = string.format(
    "curl -sS -f -X POST " ..
    "https://api.openai.com/v1/chat/completions " ..
    "-H 'Content-Type: application/json' " ..
    "-H 'Authorization: Bearer %s' " ..
    "--max-time 120 --retry 3 --retry-delay 3 " ..
    "-d '%s'",
    openai_api_key, data:gsub("'", "'\"'\"'")
  )

  local handle = io.popen(command, 'r')
  local result = handle:read('*a')
  local success = handle:close()

  if not success then
    error('Failed to execute curl command.')
  end

  if not result:match("^{") then
    error('Curl did not return a valid body: ' .. result)
  end

  local response = vim.fn.json_decode(result)
  if response.error then
    error(string.format('Failed to get response from OpenAI: %s', response.error.message))
  else
    return response.choices[1].message.content
  end
end

local function execute_lua_code(lua_code_str)
  if type(lua_code_str) ~= "string" then
    error("Input must be a string")
  end
  local func, syntaxError = loadstring(lua_code_str)
  if not func then
    error("There was a syntax error: " .. syntaxError)
  end
  return func()
end

function M.generate_code(action)
  local context  = generate_context_string()
  local prompt   = generate_prompt(context, action)
  local result   = M.ai(prompt)

  -- Remove markdown code block encoding, if any.
  -- convert local lua string variable "result" into an array
  local result_array = {}
  for substring in result:gmatch("%S+") do
      table.insert(result_array, substring)
  end

  -- Remove first item in array if it starts with ```
  if result_array[1]:sub(1, 3) == "```" then
      table.remove(result_array, 1)
  end

  -- Remove last item in array if it starts with ```
  if result_array[#result_array]:sub(1, 3) == "```" then
      table.remove(result_array)
  end
  -- convert back into a string
  result = table.concat(result_array, " ")

  return prompt, result
end

local function save_to_temp_file(wish, content)
  local temp_file = "genie-task.lua"
  local cache_dir = vim.fn.stdpath('cache') .. '/genie'
  vim.fn.mkdir(cache_dir, "p")
  local temp_file_path = cache_dir .. '/' .. temp_file

  -- Save `content` string to temporary file in Neovim's cache directory.
  local file = io.open(temp_file_path, "w")
  file:write('-' .. '-[[\n')
  file:write(wish)
  file:write('\n-' .. '-]]\n')
  file:write(content)
  file:close()
end

function M.wish(string)
  local prompt, response = M.generate_code(string)
  save_to_temp_file(prompt, response)
  execute_lua_code(response)
end

function M.setup(setup_config)
  setup_config = setup_config or {}
  M.config(setup_config)
  vim.api.nvim_create_user_command('Wish', function(args)
    M.wish(args.args)
  end, { nargs = "*" })
  return M
end

-- leak internals for testing purposes
-- Do not include in documentation.
function M.leak()
  M.execute_lua_code = execute_lua_code
  return M
end

-- Force reload of plugin.  Useful during development.
-- Do not include in documentation.
function M.reload()
  package.loaded['genie'] = nil
  return require('genie').setup(config)
end

return M
