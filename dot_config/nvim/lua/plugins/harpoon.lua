local M = {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
	},
}

function M.config()
	local harpoon = require("harpoon")

	vim.keymap.set("n", "<leader>m", function()
		harpoon:list():add()
		vim.notify("󱡅  marked file")
	end, { noremap = true, silent = true, desc = "[M]ark File" })

	vim.keymap.set("n", "<TAB>", function()
		harpoon.ui:toggle_quick_menu(harpoon:list())
	end, { noremap = true, silent = true, desc = "Quick Menu" })
end

return M
