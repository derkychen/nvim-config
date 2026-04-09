vim.pack.add({ "https://github.com/folke/flash.nvim" })

local flash = require("flash")

flash.setup({
  modes = {
    search = {
      enabled = true,
    },
  },
})

vim.keymap.set("n", "<Leader>j", flash.jump, { desc = "Flash jump" })
