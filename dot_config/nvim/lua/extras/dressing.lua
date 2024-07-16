-- Neovim plugin to improve the default vim.ui interfaces
local M = {
	"stevearc/dressing.nvim",
	event = "VeryLazy",
}

function M.config()
	require("dressing").setup({
		input = {

			-- When true, <Esc> will close the modal
			insert_only = true,

			win_options = {
				-- Window transparency (0-100)
				winblend = 10,
			},
		},
		select = {
			-- Options for nui Menu
			nui = {
				win_options = {
					winblend = 10,
				},
			},

			-- Options for built-in selector
			builtin = {
				win_options = {
					-- Window transparency (0-100)
					winblend = 10,
				},

				-- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
				-- the min_ and max_ options can be a list of mixed types.
				-- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
				-- Set to `false` to disable
				mappings = {
					["<Esc>"] = "Close",
					["<C-c>"] = "Close",
					["<CR>"] = "Confirm",
				},
			},
		},
	})
end

return M
