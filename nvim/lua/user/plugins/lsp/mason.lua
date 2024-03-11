
local function config()
  require('mason').setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })
end

return {
    "williamboman/mason.nvim",
    config = config,
}

