local M = {
	"numToStr/Comment.nvim",
	opts = {
		-- add any options here
	},
	lazy = false,
}

M.config = function()
	require("Comment").setup()
end

return M
