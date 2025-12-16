local sessions = require("sessions")

-- Tabs
vim.keymap.set("n", "<Leader>tn", function()
  vim.cmd("tabnew")
end, {})
vim.keymap.set("n", "<Leader>tx", function()
  if vim.fn.tabpagenr("$") > 1 then
    vim.cmd("tabclose")
  else
    vim.cmd("confirm qa")
  end
end, {})

-- LSP
vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, {})
vim.keymap.set("n", "<Leader>gf", vim.lsp.buf.format, {})

vim.keymap.set("n", "<Leader>do", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>dt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, {})

-- Session management
vim.keymap.set("n", "<Leader>ss", sessions.save_current, {})
vim.keymap.set("n", "<Leader>sa", sessions.save_to_name, {})
vim.keymap.set("n", "<Leader>sl", sessions.load_from_name, {})
vim.keymap.set("n", "<Leader>sdc", sessions.delete_current, {})
vim.keymap.set("n", "<Leader>sdn", sessions.delete_by_name, {})
