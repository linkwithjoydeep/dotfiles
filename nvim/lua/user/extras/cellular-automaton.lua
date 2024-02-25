
local M = {
  "eandrju/cellular-automaton.nvim",
}

function M.config()
  local wk = require "which-key"
  local commands = { "game_of_life", "make_it_rain", "scramble" } -- List of command arguments

  wk.register {
    ["<leader>y"] = {
      function()
        local command = commands[math.random(#commands)] -- Select a random command
        vim.cmd("CellularAutomaton " .. command)
      end,
      "Cellular Automaton",
    },
  }
end

return M
