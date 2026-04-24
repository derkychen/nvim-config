-- Setup all LSP servers
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

    vim.lsp.enable({
      "lua_ls",         -- Lua LSP and formatter
      "ruff",           -- Python LSP, linter, and formatter
      "texlab",         -- LaTeX LSP, latexindent for formatting
      "clangd",         -- C LSP and formatter
      "markdown_oxide", -- Markdown LSP-ish, have yet to explore PKM
      "remark_ls",      -- Markdown formatter
      "biome",          -- Web dev LSP and formatter
      "bashls",         -- Shell script LSP, shfmt for formatting
      "tombi",          -- TOML LSP and formatter
    })
  end,
  once = true,
})
