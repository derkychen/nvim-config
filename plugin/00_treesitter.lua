-- TODO: Migrate to tree-sitter-manager.nvim if it becomes stable enough, and if
-- nvim-treesitter stayes archived
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local languages = {
  "lua",
  "latex",
  "bibtex",
  "c",
  "python",
  "markdown",
  "html",
  "css",
  "javascript",
  "bash",
  "toml",
}

-- Ensure parsers for above languages are installed
local isnt_installed = function(lang)
  return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
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
