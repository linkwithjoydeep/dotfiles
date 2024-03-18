-- [[ Setting options ]]
-- See `:help vim.opt`
--  For more options, see `:help option-list`

-- Tab behaviour
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Set highlight on search
vim.opt.hlsearch = true

-- enable 24-bit colour
vim.opt.termguicolors = true

-- Controls how concealed text, such as double backticks ("``") in Markdown files, is displayed.
-- Setting it to 0 ensures that concealed text is fully visible.
vim.opt.conceallevel = 0

-- Pop up menu height and opacity
vim.opt.pumheight = 10
vim.opt.pumblend = 10

-- Show tabs
vim.opt.showtabline = 1

-- Show global status line
vim.opt.laststatus = 3

-- Stop setting terminal title to file name
vim.opt.title = false

-- This setting configures the behavior of Vim's built-in completion menu.
-- "menuone" ensures that the completion menu is always shown, even if there's only one match.
-- "noselect" prevents Vim from automatically selecting the first completion item.
vim.opt.completeopt = { "menuone", "noselect" }

--  Vim automatically adjusts indentation based on the syntax of the file you're editing.
vim.opt.smartindent = true

-- wrap lines always
vim.opt.wrap = true

-- disable netrw explorer banner and mouse support
vim.g.netrw_banner = 0
vim.g.netrw_mouse = 2
