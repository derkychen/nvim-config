# My Neovim Configuration

## Dependencies

### Required

* A C compiler
* `fzf`
* `tree-sitter`
* `basedpyright`
* `bash-language-server`
* `biome`
* `clangd`
* `latexindent`
* `lua-language-server`
* `markdown-oxide`
* `neocmakelsp`
* `remark-language-server`
* `ruff`
* `rust-analyzer`
* `shfmt`
* `stylua`
* `texlab`
* `tombi`
* `yaml-language-server`

### Optional but Recommended

* `fd`
* `rg`

## Structure

* `lsp` contains LSP configurations I copied or modified (a little).
* `lua` contains my own modules.
* `plugin` contains everything sourced at startup. Order matters for files prefixed with numbers.
