--- Configuration for the `nvim-treesitter` plugin.
---
--- Ensures parsers for a set of languages are installed. Automatically starts
--- Tree-sitter on buffers with filetypes matching these languages.
---
--- Will migrate to built-in Tree-sitter support when it becomes available:
--- https://github.com/neovim/neovim/issues/39006
---
--- Based on and thanks Evgeni Chasnovski's Neovim configuration:
--- https://github.com/echasnovski/nvim
vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })

local languages = {
  'bash',
  'bibtex',
  'c',
  'cmake',
  'comment',
  'cpp',
  'css',
  'csv',
  'doxygen',
  'html',
  'javascript',
  'json',
  'latex',
  'linkerscript',
  'lua',
  'markdown',
  'python',
  'rust',
  'toml',
  'yaml',
}

require('nvim-treesitter').install(languages)

local filetypes = vim
  .iter(languages)
  :map(vim.treesitter.language.get_filetypes)
  :flatten()
  :totable()

local treesitter_start_group =
  vim.api.nvim_create_augroup('TreesitterStart', { clear = true })

-- Start Tree-sitter on buffers when their file type is set.
vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
  group = treesitter_start_group,
})
