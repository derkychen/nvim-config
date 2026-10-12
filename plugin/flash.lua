--- Configuration for Flash.
---
--- TokyoNight configures this plugin's highlights.
vim.pack.add({ 'https://github.com/folke/flash.nvim' })

local flash = require('flash')

flash.setup()

-- Keymaps.
vim.keymap.set('n', '<Leader>j', flash.jump, { desc = 'Flash jump' })
