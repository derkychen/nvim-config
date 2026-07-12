-- TODO: Migrate to native Tree-sitter support when it becomes available:
-- https://github.com/neovim/neovim/issues/39006
vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })

-- Ensure parsers for these languages are installed
local languages = {
  "bash",
  "bibtex",
  "c",
  "cmake",
  "css",
  "csv",
  "html",
  "javascript",
  "json",
  "latex",
  "linkerscript",
  "lua",
  "markdown",
  "python",
  "toml",
  "yaml",
}

require("tree-sitter-manager").setup({
  ensure_installed = languages,
})
