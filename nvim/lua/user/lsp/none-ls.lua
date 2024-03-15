local M = {
	"nvimtools/none-ls.nvim",
}

M.config = function()
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = {
			-- Lua
			null_ls.builtins.formatting.stylua,
			-- Go
			null_ls.builtins.diagnostics.staticcheck,
			null_ls.builtins.formatting.goimports_reviser,
		},
	})

	vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "[F]ormat" })
end

return M
