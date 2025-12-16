return {
  'stevearc/aerial.nvim',
  opts = {},
  config = function()
    local aerial = require("aerial")
    aerial.setup({
      backends = { "lsp", "treesitter", "markdown", "man" },
      layout = {
        win_opts = {
          number = true,
          relativenumber = true,
          statuscolumn = " %l ",
          cursorline = true,
        },
      },
      filter_kind = false,
      show_guides = true,
      nerd_font = true,
    })
    vim.keymap.set("n", "<Leader>a", aerial.toggle, {})
    vim.keymap.set("n", "<Leader>fs", aerial.fzf_lua_picker, {})
  end,
}
