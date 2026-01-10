return {
  "lewis6991/gitsigns.nvim",
  opts = {},
  config = function()
    require('gitsigns').setup()

    vim.keymap.set("n", "<Leader>gb", function() vim.cmd("Gitsigns blame") end, { desc = "Gitsigns blame" })
    vim.keymap.set("n", "<Leader>gd", function() vim.cmd("Gitsigns diffthis") end, { desc = "Gitsigns diff" })
  end
}
