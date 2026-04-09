vim.pack.add({ "https://github.com/stevearc/aerial.nvim" })

local aerial = require("aerial")

aerial.setup({
  backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
  layout = {
    max_width = { 40, 0.25 },
    win_opts = {
      cursorline = true,
    },
    default_direction = "float",
  },
  nerd_font = true,
  show_guides = true,
})

vim.keymap.set("n", "<Leader>a", aerial.toggle, { desc = "Toggle Aerial window" })
vim.keymap.set("n", "<Leader>fs", aerial.fzf_lua_picker, { desc = "Find symbol" })
