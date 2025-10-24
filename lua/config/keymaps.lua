-- Navigate between windows in terminal, normal, and insert mode with hjkl
vim.keymap.set("n", "<C-h>", [[<C-w>h]], { noremap = true })
vim.keymap.set("n", "<C-j>", [[<C-w>j]], { noremap = true })
vim.keymap.set("n", "<C-k>", [[<C-w>k]], { noremap = true })
vim.keymap.set("n", "<C-l>", [[<C-w>l]], { noremap = true })

vim.keymap.set("i", "<C-h>", [[<Esc><C-w>h]], { noremap = true })
vim.keymap.set("i", "<C-j>", [[<Esc><C-w>j]], { noremap = true })
vim.keymap.set("i", "<C-k>", [[<Esc><C-w>k]], { noremap = true })
vim.keymap.set("i", "<C-l>", [[<Esc><C-w>l]], { noremap = true })

vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true })

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
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

-- Toggle diagnostics
vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dt", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, {})
