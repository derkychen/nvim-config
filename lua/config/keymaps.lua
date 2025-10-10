-- Toggle diagnostics
vim.keymap.set("n", "<leader>dt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, {})

-- Navigate between windows (including terminal) with hjkl
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], {noremap = true})
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], {noremap = true})
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], {noremap = true})
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], {noremap = true})

vim.keymap.set("n", "<C-h>", [[<C-w>h]], {noremap = true})
vim.keymap.set("n", "<C-j>", [[<C-w>j]], {noremap = true})
vim.keymap.set("n", "<C-k>", [[<C-w>k]], {noremap = true})
vim.keymap.set("n", "<C-l>", [[<C-w>l]], {noremap = true})
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {}) 
