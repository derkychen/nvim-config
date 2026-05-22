# My Neovim config

## Notes on general stuff

* I try to keep this config pretty minimal so I roll some of my own stuff (e.g. sessions, lazy-loading, UI2) and don't have a ton of plugins

* `lua/settings/` sets buffer-local and window-local options locally. This is intentional, as I prefer encapsulation and do not like when options for special buffers/windows are trampled. Otherwise I would use the `vim.opt` API

## Notes on structure

* Every module in the config is meant to exist nearly independently from other modules, so each module contains *additional* functionality (e.g. setup, keymaps, automatic commands, etc.)
* Everything in `lua/` is a Lua module, while files in other directories (i.e. `lsp` and `plugin`) follow the format that each special directory is intended to process (i.e. tables and source-able scripts, respectively)
* The functionality in `lua/` is utilized by some plugins
* The plugins with numbers at the beginning of their file names indicate plugins whose loading order matters, thus some of them are dependencies of other plugins
