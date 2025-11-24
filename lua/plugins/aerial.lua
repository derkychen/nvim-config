return {
  'stevearc/aerial.nvim',
  opts = {},
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-mini/mini.icons"
  },
  config = function()
    local aerial = require("aerial")
    aerial.setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      filter_kind = false,
      show_guides = true,
    })
    vim.keymap.set("n", "<Leader>a", aerial.toggle, {})
    vim.keymap.set("n", "<Leader>fs", aerial.fzf_lua_picker, {})
  end,
}
