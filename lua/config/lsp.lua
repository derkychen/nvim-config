-- Lua
vim.lsp.enable("lua_ls")

-- Python
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")

-- LaTeX
vim.lsp.enable("texlab")

-- SystemVerilog
vim.lsp.enable("verible")

-- Modelsim
vim.filetype.add({
	extension = { ["do"] = "modelsim" }, -- avoid clobbering Stata's .do
})
pcall(function()
	vim.treesitter.language.register("tcl", "modelsim")
end)
vim.lsp.enable("efm")

-- C
vim.lsp.enable("clangd")

-- Markdown
vim.lsp.enable("marksman")
vim.lsp.enable("remark_ls")

-- RISC-V
vim.lsp.enable("asm-lsp")
