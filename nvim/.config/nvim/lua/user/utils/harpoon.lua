local M = {
	"ThePrimeagen/harpoon",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
}

function M.config()
	local keymap = vim.keymap.set
	local opts = { noremap = true, silent = true }

	local harpoon_ui = require("harpoon.ui")

	keymap("n", "<s-m>", M.mark_file, opts)
	keymap("n", "<TAB>", harpoon_ui.toggle_quick_menu, opts)
end

function M.mark_file()
	require("harpoon.mark").add_file()
	vim.notify("󱡅  marked file")
end

return M
