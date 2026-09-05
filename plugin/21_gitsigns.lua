--- Configuration for the Gitsigns plugin.
vim.pack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

local gs = require('gitsigns')

gs.setup({
  -- Show blame of the current line on the right.
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text_pos = 'eol_right_align',
    delay = 500,
  },
})

-- Keymaps.
vim.keymap.set('n', '<Leader>gb', gs.blame, { desc = 'Gitsigns blame' })
vim.keymap.set('n', '<Leader>gd', gs.diffthis, { desc = 'Gitsigns diff' })
vim.keymap.set(
  'n',
  '<leader>gh',
  gs.preview_hunk,
  { desc = 'Gitsigns preview hunk' }
)
