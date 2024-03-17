local M = {
	"nvimtools/none-ls.nvim",
}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

M.on_attach = function(client, bufnr)
	if client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({
			group = augroup,
			buffer = bufnr,
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end

M.config = function()
	local null_ls = require("null-ls")
	null_ls.setup({
		sources = {
			-- Lua
			null_ls.builtins.formatting.stylua,
			-- Go
			null_ls.builtins.diagnostics.staticcheck,
			null_ls.builtins.formatting.gofumpt,
			null_ls.builtins.formatting.goimports_reviser,
			null_ls.builtins.formatting.golines,
		},
		on_attach = M.on_attach,
	})

	vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "[F]ormat" })
end

return M
