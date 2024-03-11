local function keymaps(mode, key, ops, desc, buf)
  local keymap = vim.keymap.set
  keymap(mode, key, ops, { desc = desc, buffer = buf })
end

local function loadKeymaps(buf)
  local lsp_buf = vim.lsp.buf
  local builtin = require('telescope.builtin')

  keymaps('n', 'gD', lsp_buf.declaration, "[G]oto [D]eclaration", buf)
  -- keymaps('n', 'gd', lsp_buf.definition, "[G]oto [d]efinition", buf)
  keymaps('n', 'gd', builtin.lsp_definitions, "[G]oto [d]efinition", buf)
  keymaps('n', 'K', lsp_buf.hover, "Hover", buf)
  -- keymaps('n', 'gi', lsp_buf.implementation, "[G]oto [i]mplementation", buf)
  keymaps('n', 'gi', builtin.lsp_implementations, "[G]oto [i]mplementation", buf)
  keymaps('n', '<C-k>', lsp_buf.signature_help, "Signature Help", buf)
  keymaps('n', '<leader>wa', lsp_buf.add_workspace_folder, "[A]dd Workspace Folder", buf)
  keymaps('n', '<leader>wr', lsp_buf.remove_workspace_folder, "[R]emove Workspace Folder", buf)
  keymaps('n', '<leader>wl', function()
    print(vim.inspect(lsp_buf.list_workspace_folders()))
  end, "[L]ist Workspace Folders", buf)
  keymaps('n', '<leader>D', builtin.lsp_type_definitions, "Type [D]efinition", buf)
  keymaps('n', '<leader>rn', lsp_buf.rename, "Rename", buf)
  keymaps({ 'n', 'v' }, '<leader>ca', lsp_buf.code_action, "[c]ode [a]ctions", buf)
  -- keymaps('n', 'gr', lsp_buf.references, "[G]oto [r]eferences", buf)
  keymaps('n', 'gr', builtin.lsp_references, "[G]oto [r]eferences", buf)
  keymaps('n', '<leader>f', function()
    lsp_buf.format { async = true }
  end, "[F]ormat", buf)
end

local function config()
  local lspconfig = require('lspconfig')

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function (ev)
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      loadKeymaps(ev.buf)
    end
  })



  lspconfig.lua_ls.setup({})
  lspconfig.gopls.setup({})
end

return {
  "neovim/nvim-lspconfig",
  config = config,
}
