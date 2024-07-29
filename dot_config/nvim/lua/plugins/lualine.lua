local M = {
	"nvim-lualine/lualine.nvim",
}

function M.config()
-- Bubbles config for lualine
-- Author: lokesh-krishna
-- MIT license, see LICENSE for more details.

-- stylua: ignore
local colors = {
  lavender  = '#b4befe',
  crust   = '#11111b',
}
	local bubbles_theme = {
		normal = {
			a = { fg = colors.lavender, bg = colors.crust },
			b = { fg = colors.lavender, bg = colors.crust },
			c = { fg = colors.lavender },
		},

		insert = { a = { fg = colors.lavender, bg = colors.crust } },
		visual = { a = { fg = colors.lavender, bg = colors.crust } },
		replace = { a = { fg = colors.lavender, bg = colors.crust } },

		inactive = {
			a = { fg = colors.lavender, bg = colors.lavender },
			b = { fg = colors.lavender, bg = colors.lavender },
			c = { fg = colors.lavender },
		},
	}
	require("lualine").setup({
		options = {
			theme = bubbles_theme,
			component_separators = "",
			section_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
			lualine_b = {
				{
					"filename",
					path = 1,
				},
				"branch",
			},
			lualine_c = {
				"%=" --[[ add your center compoentnts here in place of this comment ]],
			},
			lualine_x = {},
			lualine_y = { "diagnostics", "filetype", "progress" },
			lualine_z = {
				{ "location", separator = { right = "" }, left_padding = 2 },
			},
		},
		inactive_sections = {
			lualine_a = { "filename" },
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = { "location" },
		},
		tabline = {},
		extensions = { "quickfix", "man", "fugitive" },
	})
end

return M
