vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

local opts = {
  -- Tweak colour orange to be more pastel
  on_colors = function(c)
    c.orange = "#ffb070"
  end,

  on_highlights = function(hl, c)
    -- Colder syntax highlighting
    hl["@variable.builtin"].fg = c.fg
    hl["@variable.parameter"].fg = c.fg
    hl["@variable.member"].fg = c.fg
    hl["@property"].fg = c.fg
    hl["@keyword"].fg = c.cyan
    hl["@keyword.function"].fg = c.blue6
    hl["@constructor"].fg = c.blue
    hl.Statement.fg = c.cyan

    -- Match window bar background with window background
    hl.WinBar = { bg = c.bg }
    hl.WinBarNC = { fg = c.fg_gutter, bg = c.bg }

    -- Darker tab pages line background
    hl.TabLineFill.bg = c.bg_dark1

    -- Miscellaneous
    hl.MatchParen.bg = c.dark3
    hl.DiagnosticError.fg = c.red
    hl.WinSeparator.fg = c.fg_gutter
  end,
}

require("tokyonight").setup(opts)

vim.cmd.colorscheme("tokyonight")
