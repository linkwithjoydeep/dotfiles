require("user.launch")
require("user.core")

-- UI modules
--spec "user.ui.themes.github"
spec("user.ui.themes.catppuccin")
spec("user.ui.dev-icons")
spec("user.ui.fidget")
spec("user.ui.dressing")
spec("user.ui.telescope-ui-select")
spec("user.ui.noice")
spec("user.ui.lualine")
spec("user.ui.navic")
spec("user.ui.breadcrumbs")
spec("user.ui.neoscroll")
spec("user.ui.illuminate")
spec("user.ui.alpha")
spec("user.ui.indent-line")

-- Utility modules
spec("user.utils.telescope")
spec("user.utils.nvim-tree")
spec("user.utils.comment")
spec("user.utils.harpoon")
spec("user.utils.ufo")
spec("user.utils.eyeliner")
spec("user.utils.gitsigns")
spec("user.utils.autopairs")
spec("user.utils.project")
spec("user.utils.toggle-term")
spec("user.utils.navbuddy")

-- Parsers
spec("user.parsers.tree-sitter")

-- Language Server Protocol
spec("user.lsp.mason")
spec("user.lsp.mason-lsp-config")
spec("user.lsp.schemastore")
spec("user.lsp.nvim-lsp-config")
spec("user.lsp.cmp")
spec("user.lsp.none-ls")

-- Debug adapters
spec("user.dap.nvim-dap")
spec("user.dap.dap-go")

-- Testing
spec("user.testing.neotest")

-- Extras
spec("user.extras.oil")
spec("user.extras.copilot")
spec("user.extras.tabby")
spec("user.extras.modicator")

-- Misc
spec("user.misc.which-key")

require("user.lazy")
