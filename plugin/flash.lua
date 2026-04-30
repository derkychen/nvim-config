vim.pack.add({ "https://github.com/folke/flash.nvim" })

local flash = require("flash")

local opts = {
  modes = {
    search = {
      enabled = true,
    },
  },
}

flash.setup(opts)

vim.keymap.set("n", "<Leader>j", flash.jump, { desc = "Flash jump" })
