-- This file sets some keymaps for quality of life while using neovim
local keymap = vim.keymap

-- clear search highlighting on pressing <Esc> in normal mode.
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
keymap.set(
	"n",
	"[d",
	vim.diagnostic.goto_prev,
	{ desc = "Go to previous [D]iagnostic message", noremap = true, silent = true }
)
keymap.set(
	"n",
	"]d",
	vim.diagnostic.goto_next,
	{ desc = "Go to next [D]iagnostic message", noremap = true, silent = true }
)
keymap.set(
	"n",
	"<leader>e",
	vim.diagnostic.open_float,
	{ desc = "Show diagnostic [E]rror messages", noremap = true, silent = true }
)
keymap.set(
	"n",
	"<leader>q",
	vim.diagnostic.setloclist,
	{ desc = "Open diagnostic [Q]uickfix list", noremap = true, silent = true }
)

-- Exit terminal mode in the builtin terminal with a shortcut instead of <C-\><C-n>
-- NOTE: This won't work in all terminal emulators/tmux/etc. Use your own mapping
-- or just use <C-\><C-n> to exit terminal mode
keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode", noremap = true, silent = true })

-- Disable arrow keys in normal mode
keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { noremap = true, silent = true })
keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { noremap = true, silent = true })
keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { noremap = true, silent = true })
keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { noremap = true, silent = true })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window", noremap = true, silent = true })
keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window", noremap = true, silent = true })
keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window", noremap = true, silent = true })
keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window", noremap = true, silent = true })

-- Add zz to center the lines after searching
keymap.set("n", "n", "nzz", { noremap = true, silent = true })
keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
keymap.set("n", "*", "*zz", { noremap = true, silent = true })
keymap.set("n", "#", "#zz", { noremap = true, silent = true })
keymap.set("n", "g*", "g*zz", { noremap = true, silent = true })
keymap.set("n", "g#", "g#zz", { noremap = true, silent = true })

-- Indent lines left right and still stay in visual mode
keymap.set("v", "<", "<gv", { noremap = true, silent = true })
keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- prevent the replaced word from going into register when pasting over a word
keymap.set("x", "p", [["_dP]], { noremap = true, silent = true })

-- Move to the start and end of line char easily
keymap.set({ "n", "o", "x" }, "<s-h>", "^", { noremap = true, silent = true })
keymap.set({ "n", "o", "x" }, "<s-l>", "g_", { noremap = true, silent = true })

-- Map jj and jk to Esc in insert mode for quick mode switch
keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })
keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

-- Move line up and down with Alt+motion
keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", noremap = true, silent = true })
keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", noremap = true, silent = true })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down", noremap = true, silent = true }) -- move line up(v)
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up", noremap = true, silent = true })
