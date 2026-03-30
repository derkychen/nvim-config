vim.pack.add({
  "https://github.com/rafamadriz/friendly-snippets",
  { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('*') },
})

require("blink.cmp").setup()
