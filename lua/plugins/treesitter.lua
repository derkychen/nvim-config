return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup()
    local parsers = {
      "lua",
      "latex",
      "r",
      "c",
      "python",
      "markdown",
      "markdown_inline",
      "html",
      "css",
      "javascript",
      "bash",
      "toml",
    }
    local filetypes = {
      "lua",
      "tex",
      "r",
      "c",
      "python",
      "markdown",
      "html",
      "css",
      "javascript",
      "sh",
      "toml",
    }
    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
      end,
    })
  end
}
