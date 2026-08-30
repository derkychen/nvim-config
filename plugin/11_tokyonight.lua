---Configuration for the `tokyonight.nvim` plugin.
---
---Overrides some default colours and highlights. Sets the colour scheme.
vim.pack.add({ "https://github.com/folke/tokyonight.nvim" })

require("tokyonight").setup({
  on_colors = function(c)
    -- Tweak colour orange to be more pastel.
    c.orange = "#ffb070"

    -- Create the colour black for high contrast highlights.
    c.black = "#000000"
  end,

  on_highlights = function(hl, c)
    -- Colder syntax highlighting.
    hl["@module.builtin"].fg = c.fg
    hl["@variable.builtin"].fg = c.fg
    hl["@variable.parameter"].fg = c.fg
    hl["@variable.member"].fg = c.fg
    hl["@property"].fg = c.fg
    hl["@keyword"].fg = c.cyan
    hl["@keyword.function"].fg = c.blue6
    hl["@constructor"].fg = c.blue
    hl.Statement.fg = c.cyan

    -- Paler visual selection.
    hl.Visual.bg = c.blue7

    -- Softer search highlighting.
    hl.IncSearch.bg = c.green1
    hl.Search.bg = c.dark3

    -- Softer `flash.nvim` highlighting.
    hl.FlashLabel = { bg = c.blue5, fg = c.black }

    -- Match window bar background with window background.
    hl.WinBar = { bg = c.bg }
    hl.WinBarNC = { fg = c.fg_gutter, bg = c.bg }

    -- Match floating window border and popup menu border.
    hl.PmenuBorder = hl.FloatBorder

    -- Darker tab pages line background.
    hl.TabLineFill.bg = c.bg_dark1

    -- Softer error colour.
    hl.ErrorMsg.fg = c.red
    hl.DiagnosticError.fg = c.red
    hl.DiagnosticVirtualTextError.fg = c.red

    -- Miscellaneous.
    hl.MatchParen.bg = c.dark3
    hl.WinSeparator.fg = c.fg_gutter
  end,
})

vim.cmd.colorscheme("tokyonight")
