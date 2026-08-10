-- Configuration for the `flash.nvim` plugin.
--
-- NOTE: `plugin/10_tokyonight.lua` configures this plugin's highlights.
vim.pack.add({ "https://github.com/folke/flash.nvim" })

local flash = require("flash")

-- Enable `flash.nvim` enhancements to built-in search.
flash.setup({
  modes = {
    search = {
      enabled = true,
    },
  },
})

vim.keymap.set("n", "<Leader>j", flash.jump, { desc = "Flash jump" })
