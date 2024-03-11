local function config()
    require('catppuccin').setup({
      flavour = "mocha",
      transparent_background = false,
    })
    vim.cmd.colorscheme "catppuccin"
end

return {
  "catppuccin/nvim",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  name = "catppuccin",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = config,
}

