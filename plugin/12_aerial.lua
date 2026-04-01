vim.pack.add({ "https://github.com/stevearc/aerial.nvim" })

local aerial = require("aerial")

aerial.setup({
  layout = {
    max_width = { 40, 0.25 },
    win_opts = {
      cursorline = true,
    },
    default_direction = "float",
  },
  show_guides = true,
  nerd_font = true,
})

vim.keymap.set("n", "<Leader>a", aerial.toggle, { desc = "Toggle Aerial window" })
vim.keymap.set("n", "<Leader>fs", aerial.fzf_lua_picker, { desc = "Find symbol" })
