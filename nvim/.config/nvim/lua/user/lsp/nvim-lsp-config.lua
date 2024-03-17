local M = {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
}

M.dependencies = {
	{ "folke/neodev.nvim" },
}

local function keymaps(mode, key, ops, desc, buf)
	local keymap = vim.keymap.set
	keymap(mode, key, ops, { desc = desc, buffer = buf })
end

local function loadKeymaps(buf)
	local lsp_buf = vim.lsp.buf
	local builtin = require("telescope.builtin")

	keymaps("n", "gD", lsp_buf.declaration, "[G]oto [D]eclaration", buf)
	keymaps("n", "gd", builtin.lsp_definitions, "[G]oto [d]efinition", buf)
	keymaps("n", "K", lsp_buf.hover, "Hover", buf)
	keymaps("n", "gi", builtin.lsp_implementations, "[G]oto [i]mplementation", buf)
	keymaps("n", "gr", builtin.lsp_references, "[G]oto [r]eferences", buf)
	keymaps("n", "gl", vim.diagnostic.open_float, "Show Error", buf)
	keymaps("n", "<leader>gk", lsp_buf.signature_help, "Signature Help", buf)
	keymaps("n", "<leader>D", builtin.lsp_type_definitions, "Type [D]efinition", buf)
	keymaps("n", "<leader>rn", lsp_buf.rename, "Rename", buf)
	keymaps({ "n", "v" }, "<leader>ca", lsp_buf.code_action, "[c]ode [a]ctions", buf)
end

M.on_attach = function(client, bufnr)
	loadKeymaps(bufnr)

	if client.supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(bufnr, true)
	end
end

function M.common_capabilities()
	local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if ok then
		return cmp_nvim_lsp.default_capabilities()
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	return capabilities
end

M.toggle_inlay_hints = function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled(bufnr))
end

M.config = function()
	local lspconfig = require("lspconfig")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
			loadKeymaps(ev.buf)
		end,
	})

	local icons = require("user.ui.icons")
	local servers = require("user.lsp.servers")

	local default_diagnostic_config = {
		signs = {
			active = true,
			values = {
				{ name = "DiagnosticSignError", text = icons.diagnostics.Error },
				{ name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
				{ name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
				{ name = "DiagnosticSignInfo", text = icons.diagnostics.Information },
			},
		},
		virtual_text = false,
		update_in_insert = false,
		underline = true,
		severity_sort = true,
		float = {
			focusable = true,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(default_diagnostic_config)

	for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
	end

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
	vim.lsp.handlers["textDocument/signatureHelp"] =
		vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
	require("lspconfig.ui.windows").default_options.border = "rounded"

	for _, server in pairs(servers) do
		local opts = {
			on_attach = M.on_attach,
			capabilities = M.common_capabilities(),
		}

		local require_ok, settings = pcall(require, "user.lsp.lspsettings." .. server)
		if require_ok then
			opts = vim.tbl_deep_extend("force", settings, opts)
		end

		if server == "lua_ls" then
			require("neodev").setup({})
		end

		if server == "tsserver" then
			opts.init_options = {
				preferences = { disableSuggestions = true },
			}
		end

		lspconfig[server].setup(opts)
	end
end

return M
