# My Neovim config

## Notes on general stuff

* I try to keep this config pretty minimal so I roll some of my own stuff (e.g. sessions, lazy-loading) and don't have a ton of plugins

* `lua/settings.lua` sets buffer-local and window-local options locally. This is intentional, as I personally do not like when options for buffers/windows that are normal and editable are applied to other buffers/windows. Otherwise I would use the `vim.opt` API

## Notes on structure

* Everything in `lsp` and `lua` combined is supposed to work on its own, so modules are separated by function (e.g. `keymaps`, `settings`, etc.)

* Every file in `plugin` is meant to exist independently (which is useful if you want to uninstall and install safely), so each module contains all the *additional* functionality from the plugin (e.g. plugin-specific setup, keymaps, automatic commands, etc.)

## TODOs

* `plugin/heirline.lua` organization, naming, and maybe go back to old `utils.winrelpath`
* Iron out plugin loading order
* Comments in `lsp`
* Figure out how to get `ensure_installed` functionality with Mason
* Overall comments and style
