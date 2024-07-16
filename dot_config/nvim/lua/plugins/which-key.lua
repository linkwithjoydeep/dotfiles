-- In the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return {
	-- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	config = function() -- This is the function that runs, AFTER loading
		require("which-key").setup()

		-- Document existing key chains
		require("which-key").register({
			["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
			["<leader>d"] = { name = "[D]ebug", _ = "which_key_ignore" },
			["<leader>g"] = { name = "[G]oto", _ = "which_key_ignore" },
			["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
			["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
			["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
			["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
			["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
			["gs"] = { name = "[S]election", _ = "which_key_ignore" },
			["gss"] = { name = "[S]election [S]tart", _ = "which_key_ignore" },
			["gsi"] = { name = "[S]election [I]ncrement", _ = "which_key_ignore" },
			["gsd"] = { name = "[S]election [D]ecrement", _ = "which_key_ignore" },
		})
		-- visual mode
		require("which-key").register({
			["<leader>h"] = { "Git [H]unk" },
		}, { mode = "v" })
	end,
}
