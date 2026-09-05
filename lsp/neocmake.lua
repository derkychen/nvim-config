--- Neocmake LSP configuration.
---
--- Based on:
--- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#neocmake

--- @type vim.lsp.Config
return {
  cmd = { 'neocmakelsp', 'stdio' },
  filetypes = { 'cmake' },
  init_options = { format = { enable = true } },
  root_markers = { '.neocmake.toml', '.git', 'build', 'cmake' },
}
