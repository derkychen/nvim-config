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
      show_guides = true,
    })
    require("telescope").load_extension("aerial")
    vim.keymap.set("n", "<Leader>a", function()
      vim.cmd("AerialToggle")
    end)
    vim.keymap.set("n", "<Leader>fs", function()
      vim.cmd("Telescope aerial")
    end)
  end,
}
