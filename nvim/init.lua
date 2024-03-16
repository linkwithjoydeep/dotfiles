require "user.launch"
require "user.core"

-- UI modules
spec "user.ui.themes.github"
spec "user.ui.dev-icons"
spec "user.ui.fidget"
spec "user.ui.dressing"
spec "user.ui.telescope-ui-select"
spec "user.ui.noice"
spec "user.ui.lualine"

-- Utility modules
spec "user.utils.telescope"
spec "user.utils.nvim-tree"

-- Parsers
spec "user.parsers.tree-sitter"

-- Language Server Protocol
spec "user.lsp.mason"
spec "user.lsp.mason-lsp-config"
spec "user.lsp.schemastore"
spec "user.lsp.nvim-lsp-config"
spec "user.lsp.cmp"
spec "user.lsp.none-ls"

-- Debug adapters
spec "user.dap.nvim-dap"

-- Misc
spec "user.misc.which-key"

require "user.lazy"
