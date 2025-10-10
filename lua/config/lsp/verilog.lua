-- SystemVerilog/Verilog (verible)
vim.lsp.config("verible", {
  cmd = { "verible-verilog-ls", "--rules_config_search" }, -- optional flag to auto-find .rules
  -- typical filetypes
  filetypes = { "systemverilog", "verilog" },
  root_markers = { "verible.filelist", ".git" },
  -- no special settings required; server picks up .rules or flags
})
vim.lsp.enable("verible")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local o = { buffer = ev.buf, silent = true }
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, o)
	end,
})

