A lightweight, stick-to-defaults Neovim 0.11 config that aims to use the least number of plugins possible.

## Configuring an LSP with Neovim's native support

1. Navigate to [nvim-lspconfig configuration docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md) and find a supported language server.
2. To follow the natively supported format, in `lsp/` create a file of the same name as the language server, and return the default (or tweaked) configs from the document. An example with `lua_ls`:

```lua
-- lsp/lua_ls.lua
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
}
```

Not following the standard format, you can configure the language servers through the following format. However, you will have to make sure to `require` the file with your configs, since `lsp/` is a special directory and the format above is recognized by Neovim automatically.

```lua
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
})
```

For the language server to actually do stuff, enable the language server in a file required by or is `init.lua`.

```lua
vim.lsp.enable("lua_ls")
```

3. Install the language server of your choice, through a centralized plugin like [Mason](https://github.com/mason-org/mason.nvim) or through the instructions for the individual language server.
4. Restart Neovim
5. You can run a sanity check by typing `:checkhealth vim.lsp` in a buffer of the language supported by the language server you installed. You should see the language server you installed under the "Active Clients" header.
