-- file: lua/filetypes/modelsim.lua (or in init.lua)
vim.filetype.add({
  extension = { ["do"] = "modelsim" },  -- avoid clobbering Stata's .do
})

-- Reuse Tcl Treesitter for that filetype
pcall(function()
  vim.treesitter.language.register("tcl", "modelsim")
end)

-- file: lua/lsp/efm_tcl.lua
local tclint = {
  lintCommand = "tclint --stdin-path ${INPUT} -",
  lintStdin = true,
  lintFormats = { "%f:%l:%c: %t%*[^:]: %m" }, -- tclint uses readable messages; format is conservative
  formatCommand = "tclfmt",  -- provided by tclint
  formatStdin = true,
}

vim.lsp.config("efm", {
  cmd = { "efm-langserver" },
  filetypes = { "modelsim" },
  init_options = { documentFormatting = true, documentRangeFormatting = true },
  settings = {
    rootMarkers = { ".git", "tclint.toml", ".tclint" },
    languages = {
      modelsim = { tclint, tclint }, -- first = linter, second = formatter
    },
  },
})

vim.lsp.enable("efm")

