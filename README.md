# My Neovim config

## Notes on general stuff

* I try to keep this config pretty minimal so I roll some of my own stuff (e.g. sessions, lazy-loading, UI2) and don't have a ton of plugins

* `lua/settings/` sets buffer-local and window-local options locally. This is intentional, as I prefer encapsulation and do not like when options for special buffers/windows are trampled. Otherwise I would use the `vim.opt` API

## Notes on structure

* Every module in the config is meant to exist nearly independently from other modules, so each module contains *additional* functionality (e.g. setup, keymaps, automatic commands, etc.), with the functionality within the `lua/` directory taking precedent (i.e. some plugins might rely upon functionality from `lua/`)
