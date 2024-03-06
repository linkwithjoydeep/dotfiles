
local function config()
  -- recommended settings from nvim-tree documentation
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.keymap.set("n", "<C-n>", "<cmd>Neotree filesystem toggle left<CR>", {})
  -- vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})

  -- icons for diagnostic errors, you'll need to define them somewhere:
  vim.fn.sign_define("DiagnosticSignError", {text = " ", texthl = "DiagnosticSignError"})
  vim.fn.sign_define("DiagnosticSignWarn", {text = " ", texthl = "DiagnosticSignWarn"})
  vim.fn.sign_define("DiagnosticSignInfo", {text = " ", texthl = "DiagnosticSignInfo"})
  vim.fn.sign_define("DiagnosticSignHint", {text = "󰌵", texthl = "DiagnosticSignHint"})
  
  require("neo-tree").setup(
    {
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_config = {
        name = {
          use_git_status_colors = false,
        },
        git_status = {
          symbols = {
            -- Change type
            added     = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted   = "✖",-- this can only be used in the git_status source
            renamed   = "󰁕",-- this can only be used in the git_status source
            -- Status type
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".vscode", ".idea"
          },
        },
        follow_current_file = {
          enabled = true,
        },

      },
    }
  )

end


return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = config,
}
