-- TODO: Migrate to native Tree-sitter support when it becomes available:
-- https://github.com/neovim/neovim/issues/39006
vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })

-- Ensure parsers for these languages are installed
local languages = {
  "bash",
  "bibtex",
  "c",
  "css",
  "csv",
  "html",
  "javascript",
  "json",
  "latex",
  "lua",
  "markdown",
  "python",
  "toml",
  "yaml",
}

require("tree-sitter-manager").setup({
  ensure_installed = languages,
})

-- Based on and thanks Evgeni Chasnovski's Neovim configuration:
-- https://github.com/echasnovski/nvim
local treesitter_start_group =
    vim.api.nvim_create_augroup("TreesitterStart", { clear = true })

local filetypes = vim.iter(languages)
    :map(vim.treesitter.language.get_filetypes)
    :flatten()
    :totable()

vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
  group = treesitter_start_group,
  pattern = filetypes,
})
