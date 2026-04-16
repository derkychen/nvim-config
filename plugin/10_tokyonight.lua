vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

-- Highlight adjustments
require("tokyonight").setup({
  on_highlights = function(hl, c)
    hl.TabLineFill = { bg = c.bg_dark1 }
    hl.WinSeparator = { fg = c.fg_gutter }
    hl.WinBar = { bg = c.bg }
    hl.WinBarNC = { fg = c.fg_gutter, bg = c.bg }
  end,
})

vim.cmd.colorscheme("tokyonight")
