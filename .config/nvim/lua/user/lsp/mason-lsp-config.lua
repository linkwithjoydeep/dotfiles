local M = {
  "williamboman/mason-lspconfig.nvim",
}

M.dependencies = {
	{"nvim-lua/plenary.nvim"},
	{"williamboman/mason.nvim"},
}

M.config = function()
	local servers = require "user.lsp.servers"
  require('mason-lspconfig').setup({
    ensure_installed = servers,
  })
end

return M
