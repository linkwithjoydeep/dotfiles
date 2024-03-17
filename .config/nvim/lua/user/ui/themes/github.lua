local M = {
  "projekt0n/github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  name = "github",
  priority = 1000, -- make sure to load this before all the other start plugins
}

M.config = function()
    require('github-theme').setup({})
    -- available flavors @ https://github.com/projekt0n/github-nvim-theme
    vim.cmd.colorscheme "github_dark_dimmed"
end

return M