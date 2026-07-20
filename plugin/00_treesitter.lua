-- TODO: Migrate to native Tree-sitter support when it becomes available:
--       https://github.com/neovim/neovim/issues/39006
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

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

-- Based on and thanks Evgeni Chasnovski's Neovim configuration:
-- https://github.com/echasnovski/nvim
local isnt_installed = function(lang) return #vim.api.nvim_get_runtime_file(
  "parser/" .. lang .. ".*", false) == 0 end
local to_install = vim.tbl_filter(isnt_installed, languages)
if #to_install > 0 then require("nvim-treesitter").install(to_install) end

local filetypes = vim.iter(languages):map(vim.treesitter.language
.get_filetypes):flatten():totable()

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
