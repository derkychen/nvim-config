vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })

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

require("tree-sitter-manager").setup({
  ensure_installed = languages,
})

local filetypes = vim.iter(languages):map(vim.treesitter.language.get_filetypes):flatten():totable()

vim.api.nvim_create_autocmd("FileType", {
  pattern = filetypes,
  callback = function(ev)
    pcall(vim.treesitter.start, ev.buf)
  end,
})
