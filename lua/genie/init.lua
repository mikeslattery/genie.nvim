local M = {}

local PROMPT = [[INSTRUCTION:
Generate LUA CODE for Neovim to perform the ACTION to run with the `:luafile` command.
This code will run immediately, so do not generate functions or commands unless requested.
Do not require any plugins, except treesitter.nvim.
Only generate the raw Lua code, without surrounding commentary or enclosing markdown code block.
Function `require('genie').ai(prompt_string)` which can be called to ask GPT questions.

CONTEXT:
%s

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

local function generate_context_string()
  local nvim_version = vim.version()
  local os_name = vim.loop.os_uname().sysname
  local term = os.getenv("TERM")

  local editor_version_string = string.format(
    "nvim v%s.%s.%s", nvim_version.major, nvim_version.minor, nvim_version.patch)

  return string.format("EDITOR='%s', KERNEL='%s', TERM='%s'",
    editor_version_string, os_name, term)
end

-- Configuration options, with defaults
local config = {
  model = 'gpt-4',
  temperature = 0,
  access_key = os.getenv('OPENAI_API_KEY') -- Default access key from environment variable
}

function M.config(user_config)
  config = vim.tbl_deep_extend("force", config, user_config)
end

function M.get_config()
  return config
end

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

  return result
end

function M.wish(string)
  local response = M.generate_code(string)
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
