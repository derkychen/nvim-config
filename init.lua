-- Optimize startup (experimental feature)
vim.loader.enable()

-- Source these configurations in this order
require("settings")
require("keymaps")
require("lsp")
