-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
    { 
        { import = "user.plugins" },
        -- { import = "josean.plugins.lsp" }
    }, 
    {
        install = {
        colorscheme = { "catppuccin-frappe", "default" },
        },
        checker = {
        enabled = true,
        notify = false,
        },
        change_detection = {
        notify = false,
        },
  }
)




