--- StyLua LSP configuration.
---
--- Based on:
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#stylua

--- @type vim.lsp.Config
return {
  cmd = { 'stylua', '--lsp' },
  filetypes = { 'lua' },
  root_markers = { '.stylua.toml', 'stylua.toml', '.editorconfig' },
}
