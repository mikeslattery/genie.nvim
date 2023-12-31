local genie = require('genie')

describe('Genie plugin', function()
  -- This test is run by plenary
  
  -- Using a cheaper model for testing.
  MODEL = 'gpt-4-1106-preview'

  before_each(function()
    genie.leak()
    genie.setup({ model = MODEL })
  end)

  it('should set the configuration', function()
    assert.are.same(MODEL, genie.get_config().model)

    local user_config = {
      model = 'gpt-3.5-turbo'
    }
    genie.config(user_config)

    assert.are.same(user_config.model, genie.get_config().model)
    assert(genie.get_config().access_key ~= nil, 'Key cannot be nil')
    assert.are.same(0, genie.get_config().temperature)

    -- Revert
    genie.config({ model = MODEL })
  end)

  it('ai', function()
    local answer = genie.ai("The answer to 3 + 4?  Only return the raw answer.")
    assert.are.same("7", answer)
  end)

  it('generate code', function()
    local answer = genie.generate_code("Open a new tab.")
    assert.are.same("vim.cmd('tabnew')", answer)
  end)

  it('wish', function()
    local initial_tab_count = #vim.api.nvim_list_tabpages()
    genie.wish("Open a new tab.")
    local new_tab_count = #vim.api.nvim_list_tabpages()
    assert(new_tab_count == initial_tab_count + 1, "A new tab was not created.")
  end)

  it('Neovim Wish command', function()
    local initial_tab_count = #vim.api.nvim_list_tabpages()
    vim.api.nvim_command('Wish Open a new tab.')
    local new_tab_count = #vim.api.nvim_list_tabpages()
    assert(new_tab_count == initial_tab_count + 1, "A new tab was not created.")
  end)

  it('should execute Lua code', function()
    local lua_code = 'return "a" .. "b"'
    assert.are.same("ab", genie.execute_lua_code(lua_code))
  end)

end)
