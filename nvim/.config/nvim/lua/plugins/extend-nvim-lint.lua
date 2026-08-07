return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    local lint = require("lint")

    lint.linters.golangcilint.args = {
      "run",
      "--output.json.path=stdout",
      "--output.text.path=",
      "--output.tab.path=",
      "--output.html.path=",
      "--output.checkstyle.path=",
      "--output.code-climate.path=",
      "--output.junit-xml.path=",
      "--output.teamcity.path=",
      "--output.sarif.path=",
      "--issues-exit-code=0",
      "--show-stats=false",
      "--path-mode=abs",
      function()
        -- always pass the package DIRECTORY, never just the single file
        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
      end,
    }

    return opts
  end,
}
