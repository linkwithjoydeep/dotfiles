local M = {
	"leoluz/nvim-dap-go",
	ft = "go",
}

M.dependencies = { "mfussenegger/nvim-dap" }

M.config = function()
	local dap_go = require("dap-go")

	dap_go.setup({})

	vim.keymap.set("n", "<leader>dgt", dap_go.debug_test, { desc = "(D)ebug (G)o (T)est" })
	vim.keymap.set("n", "<leader>dgl", dap_go.debug_last_test, { desc = "(D)ebug (G)o (L)ast Test" })
end

return M
