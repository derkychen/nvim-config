-- Optimize startup (experimental feature)
vim.loader.enable()

-- Source these configurations in this order
require("options").setup()
require("ui2").setup()
require("sessions").setup()
require("tabs").setup()
require("diagnostics").setup()
require("lsp").setup()
