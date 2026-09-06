--- Configuration for Flash.
---
--- TokyoNight configures this plugin's highlights.
vim.pack.add({ 'https://github.com/folke/flash.nvim' })

local flash = require('flash')

-- Enable Flash enhancements to built-in search.
flash.setup({
  modes = {
    search = {
      enabled = true,
    },
  },
})

-- Keymaps.
vim.keymap.set('n', '<Leader>j', flash.jump, { desc = 'Flash jump' })
