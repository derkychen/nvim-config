return {
  'stevearc/aerial.nvim',
  opts = {},
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons"
  },
  config = function()
    require("aerial").setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      filter_kind = false,
    })
    vim.keymap.set("n", "<Leader>a", function()
      vim.cmd("AerialToggle")
    end)
  end,
}
