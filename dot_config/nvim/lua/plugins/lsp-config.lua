local M = {
	-- lsp configuration & plugins
	"neovim/nvim-lspconfig",
	dependencies = {
		-- automatically install lsps and related tools to stdpath for neovim
		{ "williamboman/mason.nvim", config = true }, -- note: must be loaded before dependants
		"williamboman/mason-lspconfig.nvim",
		-- tool installer auto installs other tools via mason
		"whoissethdaniel/mason-tool-installer.nvim",

		-- useful status updates for lsp.
		-- note: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", opts = {} },

		-- `neodev` configures lua lsp for your neovim config, runtime and plugins
		-- used for completion, annotations and signatures of neovim apis
		{ "folke/neodev.nvim", opts = {} },

		-- schema store for jsonls
		"b0o/schemastore.nvim",

		"hrsh7th/cmp-nvim-lsp",
	},
}

function M.config()
	--  this function gets run when an lsp attaches to a particular buffer.
	--    that is to say, every time a new file is opened that is associated with
	--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
	--    function will be executed to configure the current buffer
	vim.api.nvim_create_autocmd("lspattach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(event)
			-- in this case, we create a function that lets us more easily define mappings specific
			-- for lsp related items. it sets the mode, buffer and description for us each time.
			local map = function(keys, func, desc)
				vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "lsp: " .. desc })
			end

			-- jump to the definition of the word under your cursor.
			--  this is where a variable was first declared, or where a function is defined, etc.
			--  to jump back, press <c-t>.
			map("<leader>gd", require("telescope.builtin").lsp_definitions, "[g]oto [d]efinition")

			-- find references for the word under your cursor.
			map("<leader>gr", require("telescope.builtin").lsp_references, "[g]oto [r]eferences")

			-- jump to the implementation of the word under your cursor.
			--  useful when your language has ways of declaring types without an actual implementation.
			map("<leader>gi", require("telescope.builtin").lsp_implementations, "[g]oto [i]mplementation")

			-- jump to the type of the word under your cursor.
			--  useful when you're not sure what type a variable is and you want to see
			--  the definition of its *type*, not where it was *defined*.
			map("<leader>gtd", require("telescope.builtin").lsp_type_definitions, "[g]oto [t]ype [d]efinition")

			-- fuzzy find all the symbols in your current document.
			--  symbols are things like variables, functions, types, etc.
			-- map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[d]ocument [s]ymbols")

			-- fuzzy find all the symbols in your current workspace.
			--  similar to document symbols, except searches over your entire project.
			map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[w]orkspace [s]ymbols")

			-- rename the variable under your cursor.
			--  most language servers support renaming across files, etc.
			map("<leader>rn", vim.lsp.buf.rename, "[r]e[n]ame")

			-- execute a code action, usually your cursor needs to be on top of an error
			-- or a suggestion from your lsp for this to activate.
			map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")

			-- opens a popup that displays documentation about the word under your cursor
			--  see `:help k` for why this keymap.
			map("K", vim.lsp.buf.hover, "hover documentation")

			-- warn: this is not goto definition, this is goto declaration.
			--  for example, in c this would take you to the header.
			map("<leader>gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")

			-- the following autocommand is used to enable inlay hints in your
			-- code, if the language server you are using supports them
			--
			-- this may be unwanted, since they displace some of your code
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
				map("<leader>th", function()
					---@diagnostic disable-next-line: missing-parameter
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
				end, "[t]oggle inlay [h]ints")
			end
		end,
	})

	-- lsp servers and clients are able to communicate to each other what features they support.
	--  by default, neovim doesn't support everything that is in the lsp specification.
	--  when you add nvim-cmp, luasnip, etc. neovim now has *more* capabilities.
	--  so, we create new capabilities with nvim cmp, and then broadcast that to the servers.
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
	--  add any additional override configuration in the following tables. available keys are:
	--  - cmd (table): override the default command used to start the server
	--  - filetypes (table): override the default list of associated filetypes for the server
	--  - capabilities (table): override fields in capabilities. can be used to disable certain lsp features.
	--  - settings (table): override the default settings passed when initializing the server.
	--        for example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
	local servers = {
		gopls = {},
		jsonls = {
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
				},
			},
		},
		lua_ls = {
			settings = {
				lua = {
					completion = {
						callsnippet = "replace",
					},
					diagnostics = {
						globals = { "vim", "spec" },
						-- you can toggle below to ignore lua_ls's noisy `missing-fields` warnings
						disable = { "missing-fields" },
					},
				},
				runtime = {
					version = "LuaJIT",
					special = {
						spec = "require",
					},
				},
				workspace = {
					checkThirdParty = false,
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
				telemetry = {
					enable = false,
				},
			},
		},
	}

	local tools = {
		-- formatters
		"stylua",
		"goimports-reviser",
		"golines",
		-- linters
		"luacheck",
		"golangci-lint",
		-- daps
		"delve",
	}

	-- ensure the servers and tools above are installed
	--  to check the current status of installed tools and/or manually install
	--  other tools, you can run
	--    :mason
	--
	--  you can press `g?` for help in this menu.
	require("mason").setup()

	-- you can add other tools here that you want mason to install
	-- for you, so that they are available from within neovim.
	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, tools)
	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	require("mason-lspconfig").setup({
		handlers = {
			function(server_name)
				local server = servers[server_name] or {}
				-- this handles overriding only values explicitly passed
				-- by the server configuration above. useful when disabling
				-- certain features of an lsp (for example, turning off formatting for tsserver)
				server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
				require("lspconfig")[server_name].setup(server)
			end,
		},
	})
end

return M
