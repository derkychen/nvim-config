return {
  'stevearc/aerial.nvim',
  opts = {},
  config = function()
    local aerial = require("aerial")
    aerial.setup({
      layout = {
        win_opts = {
          number = true,
          relativenumber = true,
          statuscolumn = " %l ",
          cursorline = true,
        },
      },
      show_guides = true,
      nerd_font = true,
    })
    vim.keymap.set("n", "<Leader>a", aerial.toggle, { desc = "Toggle Aerial window" })
    vim.keymap.set("n", "<Leader>fs", aerial.fzf_lua_picker, { desc = "Find symbol" })
  end,
}
