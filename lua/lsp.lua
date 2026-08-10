-- LSP functionality.
--
-- Adjusts semantic highlighting to accommodate for Tree-sitter highlighting and
-- sets up LSP servers lazily.
local M = {}

-- Clear semantic highlights for comments in Lua.
local function set_semantic_hls()
  vim.api.nvim_set_hl(0, "@lsp.type.comment.lua", {})
end

function M.setup()
  -- Set semantic highlights.
  set_semantic_hls()

  local semantic_hls_group =
    vim.api.nvim_create_augroup("LSPSemanticHighlights", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = set_semantic_hls,
    group = semantic_hls_group,
  })

  -- Lazily setup all LSP servers.
  --
  -- Based on and thanks to Maria Solano's dotfiles:
  -- https://github.com/MariaSolOs/dotfiles
  local lsp_setup_group =
    vim.api.nvim_create_augroup("LSPSetup", { clear = true })

  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    callback = function()
      local servers = vim
        -- NOTE: THe file name of the LSP configuration can differ from the name
        --       of the server.
        .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
        :map(function(path)
          return vim.fs.basename(path):match("^(.*)%.lua$")
        end)
        :totable()

      vim.lsp.enable(servers)
    end,
    group = lsp_setup_group,
    once = true,
  })

  -- LSP
  vim.keymap.set(
    "n",
    "<Leader>lh",
    vim.lsp.buf.hover,
    { desc = "LSP buffer hover" }
  )
  vim.keymap.set(
    "n",
    "gd",
    vim.lsp.buf.definition,
    { desc = "LSP goto definition" }
  )
  vim.keymap.set(
    "n",
    "<Leader>la",
    vim.lsp.buf.code_action,
    { desc = "LSP code action" }
  )
  vim.keymap.set(
    "n",
    "<Leader>lf",
    vim.lsp.buf.format,
    { desc = "LSP format buffer" }
  )
end

return M
