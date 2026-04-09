vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gs = require("gitsigns")

gs.setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
  },
})

vim.keymap.set("n", "<Leader>gb", gs.blame, { desc = "Gitsigns blame" })
vim.keymap.set("n", "<Leader>gd", gs.diffthis, { desc = "Gitsigns diff" })
