---LSP functionality.
---
---Adjusts semantic highlighting to accommodate for Tree-sitter highlighting and
---sets up LSP servers lazily.
local M = {}

---Clear semantic highlights for comments in Lua.
local function set_semantic_hls()
  vim.api.nvim_set_hl(0, "@lsp.type.comment.lua", {})
end

---Set up LSP functionality.
function M.setup()
  -- Set up all LSP servers.
  --
  -- NOTE: THe file name of the LSP configuration can differ from the name
  --       of the server.
  local servers = vim
    .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
    :map(function(path)
      return vim.fs.basename(path):match("^(.*)%.lua$")
    end)
    :totable()

  vim.lsp.enable(servers)

  -- Set semantic highlights.
  set_semantic_hls()

  local semantic_hls_group =
    vim.api.nvim_create_augroup("LSPSemanticHighlights", { clear = true })

  -- Update semantic highlights on a colour scheme change.
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_semantic_hls,
    group = semantic_hls_group,
  })

  -- LSP keymaps.
  vim.keymap.set("n", "<Leader>lf", function()
    vim.lsp.buf.format({ timeout_ms = 5000 })
  end, { desc = "LSP format buffer" })
end

return M
