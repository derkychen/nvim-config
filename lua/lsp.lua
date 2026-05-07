-- Lazily setup all LSP servers
-- Based on and thanks to MariaSolOs's dotfiles:
-- https://github.com/MariaSolOs/dotfiles
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  callback = function()
    -- Extend Neovim's client capabilities with the completion ones
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      vim.lsp.config("*", {
        capabilities = blink.get_lsp_capabilities(nil, true),
      })
    end

    local servers = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
        :map(function(file)
          return vim.fn.fnamemodify(file, ":t:r")
        end)
        :totable()

    vim.lsp.enable(servers)
  end,
  once = true,
})
