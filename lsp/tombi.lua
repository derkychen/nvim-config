--- Tombi LSP configuration.
---
--- Based on:
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#tombi

--- @type vim.lsp.Config
return {
  cmd = { 'tombi', 'lsp' },
  filetypes = { 'toml' },
  root_markers = { 'tombi.toml', 'pyproject.toml', '.git' },
}
