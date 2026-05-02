vim.pack.add({ "https://github.com/mason-org/mason.nvim" })

local registry = require("mason-registry")
require("mason").setup()

-- List of packages for Mason to install, note that this list is different from
-- the list of language servers enabled in `vim.lsp.enable`
local ensure_installed = {
  "bash-language-server",
  "biome",
  "clangd",
  "latexindent",
  "lua-language-server",
  "markdown-oxide",
  "remark-language-server",
  "ruff",
  "shfmt",
  "texlab",
  "tombi",
}

for _, pkg in pairs(ensure_installed) do
  if not registry.is_installed(pkg) then
    registry.get_package(pkg):install()
  end
end
