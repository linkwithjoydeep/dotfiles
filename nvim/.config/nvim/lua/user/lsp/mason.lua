local M = {
	"williamboman/mason.nvim",
	dependencies = {
		"jay-babu/mason-nvim-dap.nvim",
		"jay-babu/mason-null-ls.nvim",
	},
}

M.config = function()
	require("mason").setup({
		ui = {
			border = "rounded",
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
		},
	})

	require("mason-nvim-dap").setup({
		ensure_installed = { "delve" },
		automatic_installation = true,
	})

	require("mason-null-ls").setup({
		ensure_installed = { "stylua", "staticcheck", "gofumt", "goimports_reviser", "golines" },
		automatic_installation = true,
	})
end

return M
