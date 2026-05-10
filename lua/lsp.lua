local M = {}

function M.setup()
  -- Lazily setup all LSP servers
  -- Based on and thanks to Maria Solano's dotfiles:
  -- https://github.com/MariaSolOs/dotfiles
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    callback = function()
      local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
          :map(function(file)
            return vim.fn.fnamemodify(file, ":t:r")
          end)
          :totable()

      vim.lsp.enable(servers)
    end,
    once = true,
  })

  -- LSP
  vim.keymap.set("n", "<Leader>lh", vim.lsp.buf.hover,
    { desc = "LSP buffer hover" })
  vim.keymap.set("n", "gd", vim.lsp.buf.definition,
    { desc = "LSP goto definition" })
  vim.keymap.set("n", "<Leader>la", vim.lsp.buf.code_action,
    { desc = "LSP code action" })
  vim.keymap.set("n", "<Leader>lf", vim.lsp.buf.format,
    { desc = "LSP format buffer" })
end

return M
