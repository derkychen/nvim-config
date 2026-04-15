local icons = require("icons")
local utils = require("utils")

vim.pack.add({ "https://github.com/rebelot/heirline.nvim" })

local hconds = require("heirline.conditions")
local hutils = require("heirline.utils")

-- Flexible component priorities
local priorities = {
  ModeText = 2,
  GitBranch = 5,
  GitDiff = 5,
  FileDir = 1,
  LSPInfo = 5,
  NavPosition = 4,
  NavPercentage = 3,
}

-- Common components
local Space = { provider = " " }
local HalfPad = { hl = { bg = "none" }, provider = "  " }
local Trunc = { provider = "%<" }
local Align = { provider = "%=" }
local Bar = { provider = "█" }
local Empty = { provider = "" }

-- Pad leftmost components on the right
local function pad_right(component)
  return {
    component,
    HalfPad,
  }
end

-- Pad rightmost components on the left
local function pad_left(component)
  return {
    HalfPad,
    component,
  }
end

-- Pad middle components symmetrically
local function pad_symmetric(component)
  return {
    HalfPad,
    component,
    HalfPad,
  }
end

-- Combine active and inactive window versions of component
local function active_inactive_win_component(active, inactive)
  return {
    fallthrough = false,
    {
      condition = hconds.is_active,
      active,
    },
    inactive,
  }
end

-- Get colors from colorscheme highlights
local function get_colors()
  local function get_hl(hl, get_bg)
    get_bg = get_bg or false
    if get_bg then
      return hutils.get_highlight(hl).bg or hutils.get_highlight("Normal").bg
    end
    return hutils.get_highlight(hl).fg or hutils.get_highlight("Normal").fg
  end
  return {
    normal = get_hl("Function"),
    insert = get_hl("Character"),
    visual = get_hl("Conditional"),
    command = get_hl("@variable.parameter"),
    replace = get_hl("@variable.builtin"),
    terminal = get_hl("@property"),
    accented_fg = get_hl("Folded"),
    accented_bg = get_hl("Folded", true),
    git_branch = get_hl("Function"),
    git_added = get_hl("GitSignsAdd"),
    git_removed = get_hl("GitSignsDelete"),
    git_changed = get_hl("GitSignsChange"),
    diag_error = get_hl("DiagnosticError"),
    diag_warn = get_hl("DiagnosticWarn"),
    diag_info = get_hl("DiagnosticInfo"),
    diag_hint = get_hl("DiagnosticHint"),
    dimmed_fg = get_hl("SpecialKey"),
    flag_fg = get_hl("@variable.parameter"),
    buffer_bufnr = get_hl("Function"),
    buffer_active_fg = get_hl("TabLineSel"),
    buffer_active_bg = get_hl("TabLineSel", true),
    buffer_inactive_fg = get_hl("TabLine"),
    buffer_inactive_bg = get_hl("TabLineFill", true),
    tab_active_highlight = get_hl("Function"),
    tab_active_fg = get_hl("StatusLine"),
    tab_active_bg = get_hl("EndOfBuffer", true),
    tab_inactive_fg = get_hl("TabLine"),
    tab_inactive_bg = get_hl("TabLineFill", true),
    statusline_inactive_fg = get_hl("StatusLineNC"),
    statusline_inactive_bg = get_hl("StatusLineNC", true),
    winbar_inactive_fg = get_hl("WinbarNC"),
    winbar_inactive_bg = get_hl("WinbarNC", true),
  }
end

-- Parent component that stores window-local information
local WinInfo = {
  init = function(self)
    self.win = vim.fn.win_getid(self.winnr)
    self.buf = vim.api.nvim_win_get_buf(self.win)
    self.bufname = vim.api.nvim_buf_get_name(self.buf)
    self.winrelpath = vim.fn.expand("%:~:.")
    self.winreldir = vim.fn.fnamemodify(self.winrelpath, ":h")
    self.filename = vim.fn.fnamemodify(self.winrelpath, ":t")
    self.filetype =
        vim.api.nvim_get_option_value("filetype", { buf = self.buf })
  end,
}

-- Parent component that stores mode information
local Mode = {
  static = {
    colors = {
      n = "normal",
      i = "insert",
      v = "visual",
      V = "visual",
      ["\22"] = "visual",
      c = "command",
      s = "visual",
      S = "visual",
      ["\19"] = "visual",
      R = "replace",
      r = "replace",
      ["!"] = "terminal",
      t = "terminal",
    },
  },
  init = function(self)
    self.mode = vim.api.nvim_get_mode().mode
    self.color = self.colors[self.mode:sub(1, 1)]
  end,
}

-- Parent component that stores Git information
local Git = {
  condition = hconds.is_git_repo,
  init = function(self)
    self.status_dict = vim.b[self.buf].gitsigns_status_dict
  end,
  hl = { bg = "accented_bg" },
}

-- Universal component for file icons
local FileIcon = {
  init = function(self)
    local get_icon = require("mini.icons").get
    local is_default = false
    self.icon, self.hl, is_default = get_icon("file", self.filename)
    if is_default then
      self.icon, self.hl = get_icon("filetype", self.filetype)
    end
  end,
  hl = function(self)
    return { fg = hutils.get_highlight(self.hl).fg }
  end,
  {
    provider = function(self)
      return self.icon
    end,
  },
  Space,
}

-- Universal component for file name
local FileName = {
  provider = function(self)
    local filename = self.filename
    if filename == "" then
      return "[No Name]"
    end
    return filename
  end,
}

-- Universal component for file flags
local FileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_get_option_value("modified", { buf = self.buf })
    end,
    Space,
    { provider = "" },
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value(
            "modifiable",
            { buf = self.buf }
          )
          or vim.api.nvim_get_option_value("readonly", { buf = self.buf })
    end,
    Space,
    {
      provider = "",
      hl = { fg = "dimmed_fg" },
    },
  },
}

-- Status line mode bars
local ModeBar = {
  hl = function(self)
    return { fg = self.color }
  end,
  Bar,
}

local ModeText = {
  static = {
    names = {
      n = "NORMAL",
      no = "O-PENDING",
      nov = "O-PENDING",
      noV = "O-PENDING",
      ["no\22"] = "O-PENDING",
      niI = "NORMAL",
      niR = "NORMAL",
      niV = "NORMAL",
      nt = "NORMAL",
      ntT = "NORMAL",
      v = "VISUAL",
      vs = "VISUAL",
      V = "V-LINE",
      Vs = "V-LINE",
      ["\22"] = "V-BLOCK",
      ["\22s"] = "V-BLOCK",
      s = "SELECT",
      S = "S-LINE",
      ["\19"] = "S-BLOCK",
      i = "INSERT",
      ic = "INSERT",
      ix = "INSERT",
      R = "REPLACE",
      Rc = "REPLACE",
      Rx = "REPLACE",
      Rv = "V-REPLACE",
      Rvc = "V-REPLACE",
      Rvx = "V-REPLACE",
      c = "COMMAND",
      cv = "EX",
      ce = "EX",
      r = "REPLACE",
      rm = "MORE",
      ["r?"] = "CONFIRM",
      ["!"] = "SHELL",
      t = "TERMINAL",
    },
  },
  flexible = priorities.ModeText,
  hl = function(self)
    return {
      fg = self.color,
      bold = true,
    }
  end,
  {
    Space,
    {
      provider = function(self)
        return "%9(" .. self.names[self.mode] .. "%)"
      end,
    },
  },
  {
    Space,
    {
      provider = function(self)
        return self.names[self.mode]
      end,
    },
  },
  {
    Space,
    {
      provider = function(self)
        return string.sub(self.names[self.mode], 1, 1)
      end,
    },
  },
  Empty,
}

local ModeIndicatorLeft = pad_right(hutils.insert(Mode, ModeBar, ModeText))

local GitBranch = hutils.insert(Git, {
  flexible = priorities.GitBranch,
  hl = { fg = "git_branch" },
  pad_symmetric({
    Space,
    {
      provider = function(self)
        local branch = self.status_dict.head
        if branch == nil or branch == "" then
          branch = "master"
        end
        return " " .. branch
      end,
    },
    Space,
  }),
  pad_symmetric({
    Space,
    { provider = "" },
    Space,
  }),
})

local FileDir = {
  flexible = priorities.FileDir,
  hl = { fg = "dimmed_fg" },
  {
    {
      provider = function(self)
        local trail = self.winreldir:sub(-1) == "/" and "" or "/"
        return self.winreldir .. trail
      end,
    },
    Space,
  },
  {
    {
      provider = function(self)
        local short_dir = vim.fn.pathshorten(self.winreldir)
        local trail = short_dir:sub(-1) == "/" and "" or "/"
        return short_dir .. trail
      end,
    },
    Space,
  },
  Empty,
}
local StatusLineFile = pad_symmetric({
  FileDir,
  FileIcon,
  FileName,
  FileFlags,
})

local Position = {
  flexible = priorities.NavPosition,
  pad_symmetric({ provider = "%21(Ln %l of %L, Col %c%)" }),
  pad_symmetric({ provider = "%10(%l/%L:%c%)" }),
  pad_symmetric({ provider = "%6(%l:%c%)" }),
  Empty,
}

local Scrollbar = {
  flexible = priorities.NavPercentage,
  pad_symmetric({
    { provider = "%P" },
    Space,
    {
      static = {
        sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" },
      },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(self.win)[1]
        local lines = vim.api.nvim_buf_line_count(self.buf)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
        return string.rep(self.sbar[i], 2)
      end,
      hl = { fg = "accented_fg", bg = "accented_bg" },
    },
  }),
  pad_symmetric({ provider = "%P" }),
  Empty,
}

local ModeBarRight = pad_left(hutils.insert(Mode, ModeBar))

-- Active statusline elements
local ActiveStatusLine = hutils.insert(
  WinInfo,
  ModeIndicatorLeft,
  GitBranch,
  Trunc,
  StatusLineFile,
  Align,
  Position,
  Scrollbar,
  ModeBarRight
)

-- Inactive statusline elements (currently unused)
local InactiveStatusLine = hutils.insert(WinInfo, {
  hl = {
    fg = "statusline_inactive_fg",
    bg = "statusline_inactive_bg",
    force = true,
  },
  pad_right(Bar),
  Trunc,
  StatusLineFile,
  Align,
  Position,
  pad_left(Bar),
})

local BreadcrumbsSep = { Space, { provider = icons.arrows.right }, Space }

local function BreadcrumbsDirItem(name)
  local get_icon = require("mini.icons").get
  local spacer
  local icon, hl
  icon, hl, _ = get_icon("directory", name)
  if icon == "" then
    spacer = nil
  else
    spacer = Space
  end
  if name ~= "" then
    return {
      {
        provider = icon,
        hl = { fg = hutils.get_highlight(hl).fg },
      },
      spacer,
      {
        hl = { fg = "dimmed_fg" },
        provider = name,
      },
    }
  end
end

local function BreadcrumbsAerialItem(symbol)
  local spacer
  local icon = symbol.icon or ""
  local name = symbol.name or ""
  if icon == "" then
    spacer = nil
  else
    spacer = Space
  end
  local kind
  if type(symbol.kind) == "string" then
    kind = symbol.kind
  elseif type(symbol.kind) == "number" then
    kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown"
  end
  if name ~= "" then
    return {
      {
        provider = icon,
        hl = { fg = hutils.get_highlight("Aerial" .. kind .. "Icon").fg },
      },
      spacer,
      {
        provider = name,
        hl = { fg = hutils.get_highlight("Aerial" .. kind).fg },
      },
    }
  end
end

local Breadcrumbs = {
  Space,
  {
    init = function(self)
      local symbols = {}
      if utils.valid_normal_buf(self.buf) and vim.uv.fs_stat(self.bufname) then
        for symbol in string.gmatch(self.winreldir, "([^/]+)") do
          table.insert(symbols, BreadcrumbsDirItem(symbol))
          table.insert(symbols, BreadcrumbsSep)
        end
      end
      table.insert(symbols, { FileIcon, FileName, FileFlags })
      for _, symbol in ipairs(require("aerial").get_location(true)) do
        table.insert(symbols, BreadcrumbsSep)
        table.insert(symbols, BreadcrumbsAerialItem(symbol))
      end
      local children = symbols
      self.child = self:new(children, 1)
    end,
    provider = function(self)
      return self.child:eval()
    end,
  },
}

-- Window bar Git diffs
local function GitDiff(type)
  return {
    static = {
      icons = {
        added = "",
        removed = "",
        changed = "󰜥",
      },
    },
    condition = function(self)
      self.count = self.status_dict[type] or 0
      return self.count > 0
    end,
    hl = { fg = "git_" .. type },
    flexible = priorities.GitDiff,
    {
      {
        provider = function(self)
          return self.icons[type]
        end,
      },
      Space,
      {
        provider = function(self)
          return self.count
        end,
      },
      Space,
    },
    {
      {
        provider = function(self)
          return self.count
        end,
      },
      Space,
    },
  }
end

-- Git diffs, displayed only when applicable
local GitDiffs = hutils.insert(Git, {
  condition = function(self)
    local types = { "added", "removed", "changed" }
    for _, type in pairs(types) do
      local count = self.status_dict[type] or 0
      if count > 0 then
        return true
      end
    end
    return false
  end,
  pad_symmetric({
    Space,
    GitDiff("added"),
    GitDiff("removed"),
    GitDiff("changed"),
  }),
})

local function Diagnostic(type)
  local icon =
      vim.diagnostic.config().signs.text[vim.diagnostic.severity[string.upper(
        type
      )]]
  return {
    condition = function(self)
      self.count = self.c[vim.diagnostic.severity[string.upper(type)]] or 0
      return self.count > 0
    end,
    flexible = priorities.LSPInfo,
    {
      Space,
      {
        provider = function(self)
          return icon .. " " .. self.count
        end,
        hl = { fg = "diag_" .. type },
      },
    },
    {
      Space,
      {
        provider = function(self)
          return self.count
        end,
        hl = { fg = "diag_" .. type },
      },
    },
  }
end

local LSPInfo = {
  init = function(self)
    self.c = vim.diagnostic.count(self.buf)
    local total = 0
    local types = { "error", "warn", "info", "hint" }
    for _, type in pairs(types) do
      total = total + (self.c[vim.diagnostic.severity[string.upper(type)]] or 0)
    end
    self.nonzero_diagnostics = total ~= 0
  end,
  pad_symmetric({
    {
      condition = hconds.lsp_attached,
      init = function(self)
        self.names = {}
        for _, server in pairs(vim.lsp.get_clients({ bufnr = self.buf })) do
          table.insert(self.names, server.name)
        end
      end,
      flexible = priorities.LSPInfo,
      {
        {
          provider = function(self)
            return " " .. table.concat(self.names, ", ")
          end,
        },
        {
          condition = hconds.has_diagnostics,
          provider = ":",
        },
      },
      {
        provider = function(self)
          if self.nonzero_diagnostics then
            return "󰨰"
          end
          return ""
        end,
      },
    },
    Diagnostic("error"),
    Diagnostic("warn"),
    Diagnostic("info"),
    Diagnostic("hint"),
  }),
}

local WindowCloseButton = {
  on_click = {
    callback = function(_, minwid)
      vim.schedule(function()
        vim.api.nvim_win_close(minwid, { force = false })
      end)
    end,
    minwid = function(self)
      return self.win
    end,
    name = "window_close_callback",
  },
  { provider = "" },
  Space,
}

-- Active window bar elements
local ActiveWinbar = hutils.insert(
  WinInfo,
  pad_right(Breadcrumbs),
  Align,
  LSPInfo,
  GitDiffs,
  pad_left(WindowCloseButton)
)

-- Inactive window bar elements
local InactiveWinbar = hutils.insert(WinInfo, {
  hl = { fg = "winbar_inactive_fg", bg = "winbar_inactive_bg", force = true },
  pad_right(Breadcrumbs),
  Align,
  LSPInfo,
  GitDiffs,
  pad_left(WindowCloseButton),
})

-- Tabline mode indicator
local ModeTabline = hutils.insert(Mode, {
  hl = function(self)
    return { fg = "black", bg = self.color }
  end,
  provider = "  ",
})

-- Tabline Buffers
local FileBufnr = {
  Space,
  {
    provider = function(self)
      return tostring(self.buf)
    end,
  },
  Space,
}

local BufferFile = {
  on_click = {
    callback = function(_, minwid, _, button)
      if button == "m" then
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = "buffer_callback",
  },
  FileBufnr,
  FileIcon,
  FileName,
  FileFlags,
}

local BufferCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value("modified", { buf = self.buf })
  end,
  Space,
  {
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
          vim.cmd.redrawtabline()
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = "buffer_close_callback",
    },
    { provider = "" },
  },
}

local Buffer = {
  init = function(self)
    self.buf = self.bufnr or 0
    self.filename =
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":t")
    self.filetype =
        vim.api.nvim_get_option_value("filetype", { buf = self.buf })
  end,
  hl = function(self)
    if self.is_active then
      return { fg = "buffer_active_fg", bg = "buffer_active_bg", force = true }
    else
      return {
        fg = "buffer_inactive_fg",
        bg = "buffer_inactive_bg",
        force = true,
      }
    end
  end,
  BufferFile,
  BufferCloseButton,
  Space,
}

local Buffers = hutils.make_buflist(Buffer)

-- Tabline tabs
local TabLine = {
  hl = { fg = "tab_active_highlight" },
  provider = function(self)
    if self.is_active then
      return "▎"
    end
    return " "
  end,
}

local TabNumber = {
  hl = { fg = "tab_active_highlight" },
  provider = function(self)
    return "%" .. self.tabnr .. "T" .. self.tabpage .. " %T"
  end,
}

local TabCloseButton = {
  provider = function(self)
    return "%" .. self.tabnr .. "X%X"
  end,
}

local Tab = {
  hl = function(self)
    if self.is_active then
      return { fg = "tab_active_fg", bg = "tab_active_bg" }
    else
      return { fg = "tab_inactive_fg", bg = "tab_inactive_bg", force = true }
    end
  end,
  TabLine,
  TabNumber,
  TabCloseButton,
  Space,
}

local Tabs = {
  condition = function()
    return #vim.api.nvim_list_tabpages() > 1
  end,
  hutils.make_tablist(Tab),
}

-- Tabline elements
local Tabline = {
  ModeTabline,
  Space,
  Trunc,
  pad_right(Buffers),
  Align,
  pad_left(Tabs),
}

-- Sign column
local Signcolumn = { provider = "%s" }

-- Line number column
local Numbercolumn = {
  condition = function(self)
    return vim.api.nvim_get_option_value("number", { win = self.win })
        or vim.api.nvim_get_option_value("relativenumber", { win = self.win })
  end,
  { provider = "%l" },
  Space,
}

-- Code folds column
local Foldcolumn = {
  condition = function(self)
    return vim.api.nvim_get_option_value("foldenable", { win = self.win })
        and vim.api.nvim_get_option_value("foldcolumn", { win = self.win }) ~= 0
        and vim.v.virtnum == 0
  end,
  { provider = "%C" },
  Space,
}

-- Statuscolumn elements
local Statuscolumn = hutils.insert(WinInfo, {
  condition = function(self)
    return utils.valid_normal_buf(self.buf)
  end,
  Space,
  Signcolumn,
  Numbercolumn,
  Foldcolumn,
})

-- Setup plugin
require("heirline").setup({
  opts = {
    disable_winbar_cb = function(ev)
      local buf = ev.buf
      local bufname = vim.api.nvim_buf_get_name(buf)
      return not (utils.valid_normal_buf(buf) and vim.uv.fs_stat(bufname))
    end,
    colors = get_colors,
  },
  statusline = active_inactive_win_component(
    ActiveStatusLine,
    InactiveStatusLine
  ),
  winbar = active_inactive_win_component(ActiveWinbar, InactiveWinbar),
  tabline = Tabline,
  statuscolumn = Statuscolumn,
})

-- Schedule redrawing of status line and tab pages line on these events to
-- prevent a delay
local heirline_redraw_group =
    vim.api.nvim_create_augroup("HeirlineRedraw", { clear = true })

local schedule_redraw_all = vim.schedule_wrap(function()
  vim.cmd.redrawstatus({ bang = true })
  vim.cmd.redrawtabline()
end)

vim.api.nvim_create_autocmd("ModeChanged", {
  callback = schedule_redraw_all,
  group = heirline_redraw_group,
})

vim.api.nvim_create_autocmd("User", {
  callback = schedule_redraw_all,
  group = heirline_redraw_group,
  pattern = "GitSignsUpdate",
})

-- Update colors on colorscheme change
local heirline_colors_group =
    vim.api.nvim_create_augroup("HeirlineColors", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    hutils.on_colorscheme(get_colors)
  end,
  group = heirline_colors_group,
})

-- Show tab pages line based on if there are listed buffers that are not visible
local heirline_tabline_group =
    vim.api.nvim_create_augroup("HeirlineTabLine", { clear = true })

vim.api.nvim_create_autocmd({
  "BufAdd",
  "BufDelete",
  "BufEnter",
  "BufWinEnter",
}, {
  callback = vim.schedule_wrap(function()
    local all_bufs_visible = true
    local bufs = vim.tbl_filter(function(buf)
      return vim.fn.buflisted(buf) == 1
    end, vim.api.nvim_list_bufs())
    local visible_bufs = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      visible_bufs[buf] = true
    end
    for _, buf in ipairs(bufs) do
      if not visible_bufs[buf] then
        all_bufs_visible = false
      end
    end
    vim.opt.showtabline = not all_bufs_visible and 2 or 1
  end),
  group = heirline_tabline_group,
})
