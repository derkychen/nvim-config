# My Neovim Configuration

## Dependencies

### Required

* A C compiler
* `fzf`
* `tree-sitter` (`tree-sitter-cli` on `brew`)

### Optional but Recommended

* `fd`
* `rg` (`ripgrep` on `brew`)

## Structure

* `lsp` contains LSP configurations I copied or modified (a little).
* `lua` contains my own modules.
* `plugin` contains everything sourced at startup. Order matters for files prefixed with numbers.
