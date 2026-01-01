return {
  "lewis6991/gitsigns.nvim",
  opts = {},
  config = function()
    require('gitsigns').setup()

    vim.keymap.set("n", "<Leader>gb", function() vim.cmd("Gitsigns blame") end, {})
  end
}
