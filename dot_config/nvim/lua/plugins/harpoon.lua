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

	vim.keymap.set("n", "<leader>a", function()
		harpoon:list():add()
		vim.notify("󱡅  added file to harpoon")
	end, { noremap = true, silent = true, desc = "[a]dd file" })

	vim.keymap.set("n", "<leader>m", function()
		harpoon.ui:toggle_quick_menu(harpoon:list())
	end, { noremap = true, silent = true, desc = "quick [m]enu" })
end

return M
