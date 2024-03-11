local function config()
    local keymap = vim.keymap.set
    local builtin = require('telescope.builtin')

    keymap('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
    keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Find in Files' })
    keymap('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
    keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags'})
end


return {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = config,
}
