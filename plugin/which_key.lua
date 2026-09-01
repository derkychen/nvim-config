---Configuration for the WhichKey plugin.
vim.pack.add({ 'https://github.com/folke/which-key.nvim' })

require('which-key').setup({
  -- Use the Helix-style keymap window.
  preset = 'helix',

  win = {
    -- Make the floating window border match `vim.o.winborder`
    border = vim.o.winborder,

    -- Remove extra padding on the right.
    col = math.huge,
  },
})
