-- TODO: Migrate to native Tree-sitter support when it becomes available:
-- https://github.com/neovim/neovim/issues/39006

-- Based on and thanks Evgeni Chasnovski's Neovim configuration:
-- https://github.com/echasnovski/nvim
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

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
}

-- Ensure parsers for above languages are installed
local isnt_installed = function(language)
  return
      #vim.api.nvim_get_runtime_file("parser/" .. language .. ".*", false) == 0
end
local to_install = vim.tbl_filter(isnt_installed, languages)
if #to_install > 0 then
  require("nvim-treesitter").install(to_install)
end

-- Start Tree-sitter on buffers of filetypes corresponding to languages
local treesitter_start_group =
    vim.api.nvim_create_augroup("TreesitterStart", { clear = true })

local filetypes = vim
    .iter(languages)
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
