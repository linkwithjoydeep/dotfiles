-- Neovim plugin for automatically highlighting other uses of the word under the cursor
-- using either LSP, Tree-sitter, or regex matching.
-- You'll also get <a-n> and <a-p> as keymaps to move between references
-- and <a-i> as a textobject for the reference illuminated under the cursor.
local M = {
	"RRethy/vim-illuminate",
	event = "VeryLazy",
}

function M.config()
	require("illuminate").configure({
		filetypes_denylist = {
			"mason",
			"harpoon",
			"DressingInput",
			"NeogitCommitMessage",
			"qf",
			"dirvish",
			"oil",
			"minifiles",
			"fugitive",
			"alpha",
			"NvimTree",
			"lazy",
			"NeogitStatus",
			"Trouble",
			"netrw",
			"lir",
			"DiffviewFiles",
			"Outline",
			"Jaq",
			"spectre_panel",
			"toggleterm",
			"DressingSelect",
			"TelescopePrompt",
		},
	})
end

return M
