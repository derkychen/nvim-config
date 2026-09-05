--- Ruff LSP configuration.
---
--- Based on:
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ruff

--- @type vim.lsp.Config
return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  settings = {},
}
