local M = {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
			-- "theHamsta/nvim-dap-virtual-text",
			-- "nvim-telescope/telescope-dap.nvim",
		},
	},
}

function M.config()
	local dap = require("dap")
	local dapui = require("dapui")

	require("dapui").setup()

	-- Debuggers for languages
	require("dap-go").setup()

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

	vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "[d]ebug Toggle [b]reakpoint" })
	vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[d]ebug [c]ontinue" })
end

return M
