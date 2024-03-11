local function config()
  require('mason-lspconfig').setup({
    ensure_installed = {
      "lua_ls",
      "gopls",
    },
  })
end

return {
  "williamboman/mason-lspconfig.nvim",
  config = config,
}
