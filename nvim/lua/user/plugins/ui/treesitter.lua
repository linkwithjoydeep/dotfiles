local function config()
  require('nvim-treesitter.configs').setup({
    ensure_installed = {"lua", "vim", "javascript", "go", "json", "yaml"},
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
  })
end

return {
  'nvim-treesitter/nvim-treesitter',
  build = ":TSUpdate",
  config = config,
}
