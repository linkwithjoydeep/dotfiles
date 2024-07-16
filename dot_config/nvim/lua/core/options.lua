-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Make line numbers default
vim.opt.number = true
-- Ralative line numbers on
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits and debug
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- visually indents wrapped lines to match the indentation of the preceding line
vim.opt.breakindent = true
-- automatically adjusts the indentation of new lines to match the structure of the code
vim.opt.smartindent = true

-- Save undo history
vim.opt.undofile = true
-- Vim will not create temporary files to store the current state of the editing session.
-- This may reduce disk usage but also means that unsaved changes cannot be recovered in case of a crash
vim.opt.swapfile = false

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time; faster completion
vim.opt.updatetime = 100

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
-- opt.list = true
-- opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- Minimal number of columns to keep left and right of the cursor
vim.opt.sidescrolloff = 8

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- Tab behaviour
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- make selecting in visual block mode a little easier
vim.opt.virtualedit = "block"

-- enable 24-bit colour
vim.opt.termguicolors = true

-- Controls how concealed text, such as double backticks ("``") in Markdown files, is displayed.
-- Setting it to 0 ensures that concealed text is fully visible.
vim.opt.conceallevel = 0

-- Stop setting terminal title to file name
vim.opt.title = false

-- Pop up menu height and opacity
vim.opt.pumheight = 10
vim.opt.pumblend = 10

-- Show tabs
vim.opt.showtabline = 1

-- Show global status line
vim.opt.laststatus = 3

-- disable the ruler that shows cursor position in status line
vim.opt.ruler = false

-- disables the display of partially typed commands
vim.opt.showcmd = false

-- This setting configures the behavior of Vim's built-in completion menu.
-- "menuone" ensures that the completion menu is always shown, even if there's only one match.
-- "noselect" prevents Vim from automatically selecting the first completion item.
vim.opt.completeopt = { "menuone", "noselect" }

-- tells Vim to be less chatty by not showing messages like "match" or "no match" when using autocomplete
vim.opt.shortmess:append("c")

-- Fill chars for folds
vim.opt.fillchars = vim.opt.fillchars + "eob: "
vim.opt.fillchars:append({
	stl = " ",
})

-- wrap lines always
vim.opt.wrap = true

-- allow the cursor to move smoothly across certain characters (`<`, `>`, `[`, `]`) and
-- to wrap around the end of lines (`h`, `l`).
vim.cmd("set whichwrap+=<,>,[,],h,l")

-- adding hyphen (`-`) to the list of characters considered part of a keyword
vim.cmd([[set iskeyword+=-]])

-- disable netrw explorer banner and mouse support
vim.g.netrw_banner = 0
vim.g.netrw_mouse = 2
