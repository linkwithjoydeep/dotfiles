local M = {
	"mfussenegger/nvim-dap",
}

M.dependencies = {
	"rcarriga/nvim-dap-ui",
}

M.config = function()
	local dap, dapui = require("dap"), require("dapui")

	-- require("dap.ext.vscode").load_launchjs()

	require("dapui").setup({})

	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
	vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step (o)ver" })
	vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step (I)nto" })
	vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step (O)ut" })
end

return M
