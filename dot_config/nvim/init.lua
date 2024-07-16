-- core modules
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- custom launch file to setup lazy specs
require("custom.launch")

spec("plugins.catppuccin") -- Color scheme
spec("plugins.web-devicons")
spec("plugins.treesitter") -- parsers
spec("plugins.neo-tree")
spec("plugins.completion")
spec("plugins.lsp-config") -- language servers
spec("plugins.telescope")
spec("plugins.formatter")
spec("plugins.linter")
spec("plugins.autopairs")
spec("plugins.illuminate")
spec("plugins.gitsigns")
spec("plugins.which-key")
spec("plugins.mini")
spec("plugins.lualine")
spec("plugins.harpoon")
spec("plugins.indent-line")

-- Extras
spec("extras.todo-highlighter")
spec("extras.dressing")
spec("extras.eyeliner")
spec("extras.oil")
spec("extras.folds")

-- lazy package manager
require("custom.lazy")
