local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("config")
require("lazy").setup("plugins")

-- Lua
vim.lsp.enable("lua_ls")
vim.lsp.enable("stylua")

-- Python
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")

-- LaTeX
vim.lsp.enable("texlab")

-- SystemVerilog
vim.lsp.enable("verible")

-- Modelsim
vim.filetype.add({
  extension = { ["do"] = "modelsim" },  -- avoid clobbering Stata's .do
})
pcall(function()
  vim.treesitter.language.register("tcl", "modelsim")
end)
vim.lsp.enable("efm")
