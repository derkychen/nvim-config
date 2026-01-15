return {
  "lewis6991/gitsigns.nvim",
  opts = {},
  config = function()
    local gs = require("gitsigns")
    gs.setup({
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
    })

    vim.keymap.set("n", "<Leader>gb", gs.blame, { desc = "Gitsigns blame" })
    vim.keymap.set("n", "<Leader>gb", gs.diffthis, { desc = "Gitsigns diff" })
  end
}
