return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
    require("tokyonight").setup({
      on_highlights = function(hl, c)
        hl.TabLineFill = { bg = c.bg_dark1 }
        hl.WinSeparator = { fg = c.bg_highlight }
        hl.WinBar = { bg = "none" }
        hl.WinBarNC = { fg = c.fg_gutter, bg = "none" }
      end,
    })
    vim.cmd.colorscheme("tokyonight")
  end,
}

