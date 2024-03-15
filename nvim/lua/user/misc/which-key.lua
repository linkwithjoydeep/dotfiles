local M = {
  'folke/which-key.nvim',
  event = 'VeryLazy',
}

M.config = function()
  require('which-key').setup()

  -- Document existing key chains
  require('which-key').register {
    ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
    ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
    ['<leader>e'] = { name = '[E]xplorer', _ = 'which_key_ignore' },
    ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
    ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
    ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
    ['<leader>f'] = { name = '[F]ile', _ = 'which_key_ignore' },
    ['gw'] = { name = '[W]indow', _ = 'which_key_ignore' },
  }
end

return M