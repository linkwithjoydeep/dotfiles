local M = {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
}

function M.config()
	local lint = require("lint")

	-- Add linters per fle type
	-- Run Cmd `:lua print(vim.bo.filetype)` to get the opened file type
	-- additionally add the linters in the `tools` table of `lsp-config` plugin for auto installation
	lint.linters_by_ft = {
		lua = { "luacheck" },
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
	}

	-- make luacheck aware of the `vim` global
	lint.linters.luacheck.args = {
		"--global",
		"vim",
		"lvim",
		"reload",
		"--",
	}

	local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
		group = lint_augroup,
		callback = function()
			lint.try_lint()
		end,
	})

	vim.keymap.set("n", "<leader>l", function()
		lint.try_lint()
	end, { desc = "[L]int File" })
end

return M
