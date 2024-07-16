-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- automatically adjust the sizes of all windows across all tabs whenever the Neovim window is resized.
vim.api.nvim_create_autocmd("VimResized", {
	desc = "Resize all tabs equally when the Vim window is resized",
	group = vim.api.nvim_create_augroup("auto-tab-resize", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

-- automatically check for any changes to the file on disk when a buffer window is entered
-- This helps keep the buffer content up-to-date with the file's actual state,
-- ensuring that any external modifications to the file are recognized and reflected in Neovim
vim.api.nvim_create_autocmd("BufWinEnter", {
	desc = "Check for changes to the file on disk when a buffer is entered",
	group = vim.api.nvim_create_augroup("auto-checktime", { clear = true }),
	pattern = { "*" },
	callback = function()
		vim.cmd("checktime")
	end,
})

-- Removes continuous comment line behavior
vim.api.nvim_create_autocmd("BufWinEnter", {
	desc = "Set formatoptions options when entering a buffer window",
	group = vim.api.nvim_create_augroup("auto-formatoptions", { clear = true }),
	callback = function()
		vim.cmd("set formatoptions-=cro")
	end,
})

-- Close the certain window types with just q
vim.api.nvim_create_autocmd("FileType", {
	desc = "Close certain window types with q",
	group = vim.api.nvim_create_augroup("filetype-settings", { clear = true }),
	pattern = {
		"netrw",
		"Jaq",
		"qf",
		"git",
		"help",
		"man",
		"lspinfo",
		"oil",
		"spectre_panel",
		"lir",
		"DressingSelect",
		"tsplayground",
		"",
	},
	callback = function()
		vim.cmd([[
      nnoremap <silent> <buffer> q :close<CR>
      set nobuflisted
    ]])
	end,
})

-- Automatically quit weird command window entered with q
vim.api.nvim_create_autocmd("CmdWinEnter", {
	desc = "Automatically quit the command window when it is entered",
	group = vim.api.nvim_create_augroup("auto-quit-cmdwin", { clear = true }),
	callback = function()
		vim.cmd("quit")
	end,
})

-- Fix weird cursor jumps when you press tab without completing a lua snippet
vim.api.nvim_create_autocmd("CursorHold", {
	desc = "Handle CursorHold event to unlink current snippet in luasnip",
	group = vim.api.nvim_create_augroup("handle-cursorhold", { clear = true }),
	callback = function()
		local status_ok, luasnip = pcall(require, "luasnip")
		if not status_ok then
			return
		end
		if luasnip.expand_or_jumpable() then
			vim.cmd([[silent! lua require("luasnip").unlink_current()]])
		end
	end,
})
