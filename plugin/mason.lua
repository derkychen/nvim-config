--- Configuration for the `mason.nvim` plugin.
---
--- Ensures a set of LSP servers are installed and tweaks `mason.nvim`'s UI.
vim.pack.add({ 'https://github.com/mason-org/mason.nvim' })

require('mason').setup({
  ui = {
    -- Do not darken window backdrop.
    backdrop = 100,
  },
})

-- `mason.nvim` ensures installation of these packages.
--
-- NOTE: That this list is different from the list of language servers enabled
--       in `vim.lsp.enable`.
local ensure_installed = {
  'basedpyright',
  'bash-language-server',
  'biome',
  'clangd',
  'latexindent',
  'lua-language-server',
  'markdown-oxide',
  'neocmakelsp',
  'remark-language-server',
  'ruff',
  'rust-analyzer',
  'shfmt',
  'stylua',
  'texlab',
  'tombi',
  'yaml-language-server',
}

local registry = require('mason-registry')

for _, pkg in pairs(ensure_installed) do
  if not registry.is_installed(pkg) then
    registry.get_package(pkg):install()
  end
end
