---LSP functionality.
---
---Adjusts semantic highlighting to accommodate for Tree-sitter highlighting and
---sets up LSP servers lazily.

-- Set up all LSP servers.
--
-- The file name of the LSP configuration can differ from the name of the
-- server. However, clients will be listed by the name of their configuration.
vim.lsp.enable(vim
  .iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
  :map(function(path)
    return vim.fs.basename(path):match('^(.*)%.lua$')
  end)
  :totable())

---Clear semantic highlights for comments in Lua.
---
---This is an exception, as it seems that Tree-sitter parsing is overridden by
---LSP when it should not be (e.g. for `TODO` or `NOTE` comments).
local function set_lua_semantic_hls()
  vim.api.nvim_set_hl(0, '@lsp.type.comment.lua', {})
end

local semantic_hls_group =
  vim.api.nvim_create_augroup('LSPSemanticHighlights', { clear = true })

-- Update semantic highlights on a colour scheme change.
set_lua_semantic_hls()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_lua_semantic_hls,
  group = semantic_hls_group,
})

-- Keymaps.
vim.keymap.set('n', '<Leader>lf', function()
  vim.lsp.buf.format({ timeout_ms = 5000 })
end, { desc = 'LSP format buffer' })
