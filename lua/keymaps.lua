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
vim.keymap.set("n", "<Leader>lh", vim.lsp.buf.hover, { desc = "LSP buffer hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP goto definition" })
vim.keymap.set("n", "<Leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
vim.keymap.set("n", "<Leader>lf", vim.lsp.buf.format, { desc = "LSP format buffer" })

vim.keymap.set("n", "<Leader>do", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Open diagnostic" })
vim.keymap.set("n", "<Leader>dt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
