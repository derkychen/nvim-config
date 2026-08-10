-- Configuration entry point.

-- Optimize startup (experimental feature).
vim.loader.enable()

-- This setup function must before the others.
require("options").setup()

-- The order of the following setup functions does not matter.
require("diagnostics").setup()
require("help").setup()
require("lsp").setup()
require("sessions").setup()
require("tabs").setup()
require("ui2").setup()
