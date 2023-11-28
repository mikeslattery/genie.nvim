-- lua/genie/init.lua
local M = {}

local PROMPT = [[INSTRUCTION:
Generate Lua code for Neovim to perform the ACTION to run with the `:luafile` command.
This code will run immediately, so do not generate functions or command.
Do not require any plugins, except treesitter.nvim.
Only generate the raw Lua code, excluding any markdown enclosure.
There is a global function called `ai(prompt_string)` which can be called to ask GPT questions.
There is a global function called `text_to_speech(text, language)`.

CONTEXT:
%s

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
  local current_time = os.date("%Y-%m-%d %H:%M:%S")

  local editor_version_string = string.format(
    "nvim v%s.%s.%s", nvim_version.major, nvim_version.minor, nvim_version.patch)

  local term_string = term

  return string.format("EDITOR='%s', OS='%s', TERM='%s', DATETIME='%s'",
    editor_version_string, os_name, term_string, current_time)
end

local function request_to_openai(prompt)
  local curl = require('plenary.curl')
  local openai_api_key = os.getenv('OPENAI_API_KEY') -- Load API key from environment variable

  if not openai_api_key then
    error('The environment variable OPENAI_API_KEY is not set.')
  end

  local response = curl.post('https://api.openai.com/v1/chat/completions', {
    headers = {
      ['Content-Type'] = 'application/json',
      ['Authorization'] = 'Bearer ' .. openai_api_key -- Use the loaded API key
    },
    body = vim.fn.json_encode({
      model = "gpt-3.5-turbo",
      messages = {
        {
          role = "user",
          content = prompt
        }
      }
    })
  })

  if response.status == 200 then
    local result = vim.fn.json_decode(response.body)
    return result.choices[1].message.content
  else
    error('Failed to get response from OpenAI: ' .. response.status)
  end
end

local function execute_lua_code(lua_code_str)
  assert(type(lua_code_str) == "string", "Expected a string")
  local func, syntax_error = load(lua_code_str)
  if not func then
    error("Syntax error in lua code: " .. syntax_error)
  end
  local success, runtime_error = pcall(func)
  if not success then
    error("Runtime error in lua code: " .. runtime_error)
  end
end

function M.setup()
  vim.api.nvim_create_user_command('Wish', function(args)
    local context = generate_context_string()
    local action = args.args
    local prompt = generate_prompt(context, action)
    local response = request_to_openai(prompt)
    execute_lua_code(response)
  end, { nargs = "*" })
end

return M

--[[TODO:
1. Error handling could be improved by providing more detailed messages or handling specific error cases more gracefully.
2. The plugin assumes the presence of the 'plenary.curl' module without checking if it's installed, which could lead to runtime errors if the module is missing.
3. The plugin uses global functions `ai(prompt_string)` and `text_to_speech(text, language)` without defining them, which might cause errors if they are not defined elsewhere in the user's environment.
4. The plugin does not sanitize the action input, which could potentially lead to the execution of unintended code if the input is not properly validated.
5. The plugin does not provide any feedback to the user about the status of the request or the execution of the Lua code, which could be improved by adding print statements or other forms of user feedback.
--]]
