-- Configuration for the `nvim-treesitter` plugin.
--
-- Ensures parsers for a set of languages are installed. Automatically starts
-- Tree-sitter on buffers with filetypes matching these languages.
--
-- TODO: Migrate to native Tree-sitter support when it becomes available:
--       https://github.com/neovim/neovim/issues/39006
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local languages = {
  "bash",
  "bibtex",
  "c",
  "cmake",
  "comment",
  "cpp",
  "css",
  "csv",
  "doxygen",
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

require("nvim-treesitter").install(languages)

-- Start Tree-sitter on relevant buffers.
--
-- Based on and thanks Evgeni Chasnovski's Neovim configuration:
-- https://github.com/echasnovski/nvim
local filetypes = vim
  .iter(languages)
  :map(vim.treesitter.language.get_filetypes)
  :flatten()
  :totable()

local treesitter_start_group =
  vim.api.nvim_create_augroup("TreesitterStart", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
  group = treesitter_start_group,
})
