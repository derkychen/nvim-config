-- TeX (texlab)
vim.lsp.config("texlab", {
  cmd = { "texlab" },
  filetypes = { "tex", "bib" },
  -- choose your project roots; .git is fine, but latexmkrc is handy too
  root_markers = { ".latexmkrc", ".git" },
  settings = {
    texlab = {
      auxDirectory = ".",
      bibtexFormatter = "texlab",
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = false,            -- set true if you want auto build on save
        forwardSearchAfter = false
      },
      chktex = { onOpenAndSave = false, onEdit = false },
      diagnosticsDelay = 300,
      formatterLineLength = 80,
      latexFormatter = "latexindent",
      latexindent = { modifyLineBreaks = false },
      forwardSearch = { args = {} },
    },
  },
})
vim.lsp.enable("texlab")

