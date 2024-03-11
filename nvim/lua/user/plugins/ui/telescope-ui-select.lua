
local function config()
  -- This is your opts table
  require("telescope").setup {
    extensions = {
      ["ui-select"] = {
        require("telescope.themes").get_dropdown {
        }
      }
    }
  }
  -- To get ui-select loaded and working with telescope, you need to call load_extension
  require("telescope").load_extension("ui-select")
end

return {
  'nvim-telescope/telescope-ui-select.nvim',
  config = config,
}
