--- Configuration for Heirline.
---
--- This configuration is responsible for the statusline, statuscolumn, window
--- bar, tab pages line. Mini Icons, Aerial, and Gitsigns must be set up before
--- this configuration is sourced.
local icons = require('icons')
local utils = require('utils')
local micons = require('mini.icons')
local aerial = require('aerial')

vim.pack.add({ 'https://github.com/rebelot/heirline.nvim' })

local hconds = require('heirline.conditions')
local hutils = require('heirline.utils')

-- Flexible component priorities.
local priorities = {
  low = 1,
  medium = 2,
  high = 3,
}

-- Spacing components.
local InertSpace = { provider = ' ' }
local HalfPad = { hl = { bg = 'none' }, provider = '  ' }

-- Special components.
local Trunc = { provider = '%<' }
local Align = { provider = '%=' }
local Empty = {}

--- Escapes strings that can contain special statusline character '%'.
---
--- This function is only used for strings to be rendered that are arbitrary
--- (i.e., not controlled by this configuration).
---
--- @param str string String to escape.
--- @return string escaped String with `%` escaped.
local function escape(str)
  local escaped = str:gsub('%%', '%%%%')
  return escaped
end

--- Joins components with a separator.
---
--- @param components table Components to join.
--- @param separator table Separator component.
--- @return table joined Joined component.
local function join(components, separator)
  local joined = {}

  for i = 1, #components - 1 do
    joined[#joined + 1] = components[i]
    joined[#joined + 1] = separator
  end

  joined[#joined + 1] = components[#components]

  return joined
end

--- Pads leftmost components on the right.
---
--- @param component table Component to pad on the right.
--- @return table padded Component with padding on the right.
local function pad_right(component)
  return {
    component,
    HalfPad,
  }
end

--- Pads rightmost components on the left.
---
--- @param component table Component to pad on the left.
--- @return table padded Component with padding on the left.
local function pad_left(component)
  return {
    HalfPad,
    component,
  }
end

--- Pads middle components symmetrically.
---
--- @param component table Component to pad symmetrically.
--- @return table padded Component with symmetric padding.
local function pad_symmetric(component)
  return {
    HalfPad,
    component,
    HalfPad,
  }
end

--- Combines active and inactive window versions of component.
---
--- @param active table Component when active.
--- @param inactive table Component when inactive.
--- @return table padded Combined component.
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

--- Gets colours from colour scheme highlights.
local function get_colours()
  --- Gets the foreground of a highlight with a fallback.
  ---
  --- @param hl string Highlight name.
  --- @return integer colour RGB colour value for the highlight's foreground.
  local function get_fg(hl)
    return hutils.get_highlight(hl).fg or hutils.get_highlight('StatusLine').fg
  end

  --- Gets the background of a highlight with a fallback.
  ---
  --- @param hl string Highlight name.
  --- @return integer colour RGB colour value for the highlight's background.
  local function get_bg(hl)
    return hutils.get_highlight(hl).bg or hutils.get_highlight('StatusLine').bg
  end

  return {
    normal = get_fg('Function'),
    insert = get_fg('Character'),
    visual = get_fg('Identifier'),
    command = get_fg('WarningMsg'),
    replace = get_fg('DiagnosticError'),
    terminal = get_fg('DiagnosticHint'),
    macro_rec = get_fg('CursorLineNr'),
    macro_reg = get_fg('String'),
    git_bg = get_bg('Folded'),
    git_branch = get_fg('Function'),
    git_added = get_fg('GitSignsAdd'),
    git_removed = get_fg('GitSignsDelete'),
    git_changed = get_fg('GitSignsChange'),
    diagnostics_error = get_fg('DiagnosticError'),
    diagnostics_warn = get_fg('DiagnosticWarn'),
    diagnostics_info = get_fg('DiagnosticInfo'),
    diagnostics_hint = get_fg('DiagnosticHint'),
    dir_fg = get_fg('StatusLineNC'),
    unmodifiable_fg = get_fg('StatusLineNC'),
    scrollbar_fg = get_fg('Function'),
    scrollbar_bg = get_bg('Folded'),
    breadcrumbs_dir_fg = get_fg('StatusLineNC'),
    buffer_bufnr = get_fg('TabLineSel'),
    buffer_active_fg = get_fg('TabLineSel'),
    buffer_active_bg = get_bg('TabLineSel'),
    buffer_inactive_fg = get_fg('TabLine'),
    buffer_inactive_bg = get_bg('TabLineFill'),
    tab_active_highlight = get_bg('TabLineSel'),
    tab_active_fg = get_fg('StatusLine'),
    tab_active_bg = get_bg('Normal'),
    tab_inactive_fg = get_fg('TabLine'),
    tab_inactive_bg = get_bg('TabLineFill'),
    statusline_inactive_fg = get_fg('StatusLineNC'),
    statusline_inactive_bg = get_bg('StatusLineNC'),
    winbar_inactive_fg = get_fg('WinBarNC'),
    winbar_inactive_bg = get_bg('WinBarNC'),
  }
end

-- Data storing components.
--
-- These components do not have providers, as they are not rendered. However,
-- they do store data relevant to rendering, such as text and highlights.
local WinData = {
  condition = function(self)
    self.win = vim.fn.win_getid(self.winnr)
    return vim.api.nvim_win_is_valid(self.win)
  end,
  init = function(self)
    self.buf = vim.api.nvim_win_get_buf(self.win)
    self.buf_is_valid_normal_disk = utils.valid_normal_disk_buf(self.buf)
    self.filetype =
      vim.api.nvim_get_option_value('filetype', { buf = self.buf })

    local bufname = vim.api.nvim_buf_get_name(self.buf)
    local display_bufname = bufname

    -- Display a window-relative path for valid, normal, disk buffers.
    if self.buf_is_valid_normal_disk then
      display_bufname = utils.relpath(vim.fn.getcwd(self.win), display_bufname)
    end

    self.bufhead = vim.fs.dirname(display_bufname)
    self.buftail = vim.fs.basename(display_bufname)
  end,
}

local ModeData = {
  static = {
    colours = {
      n = 'normal',
      i = 'insert',
      v = 'visual',
      V = 'visual',
      ['\x16'] = 'visual',
      c = 'command',
      s = 'visual',
      S = 'visual',
      ['\x13'] = 'visual',
      R = 'replace',
      r = 'replace',
      ['!'] = 'terminal',
      t = 'terminal',
    },
  },
  init = function(self)
    self.mode = vim.api.nvim_get_mode().mode
    self.colour = self.colours[self.mode:sub(1, 1)]
  end,
}

local GitData = {
  condition = function(self)
    self.status_dict = vim.b[self.buf].gitsigns_status_dict
    return self.status_dict ~= nil
  end,
  hl = { bg = 'git_bg' },
}

-- Reused components.
--
-- Each of these components are used by multiple, other, components.
local BufferIcon = {
  init = function(self)
    local is_default

    -- Get the icon for the buffer name tail.
    self.icon, self.icon_hl, is_default = micons.get('file', self.buftail)

    -- Fall back to buffer file type.
    if is_default then
      self.icon, self.icon_hl = micons.get('filetype', self.filetype)
    end
  end,
  hl = function(self)
    return self.icon_hl
  end,
  provider = function(self)
    return self.icon .. ' '
  end,
}

local BufferNameTail = {
  provider = function(self)
    if self.buftail == '' then
      return '[No Name]'
    end

    return escape(self.buftail)
  end,
}

local BufferFlags = {
  {
    condition = function(self)
      return vim.api.nvim_get_option_value('modified', { buf = self.buf })
    end,
    provider = ' ',
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value(
          'modifiable',
          { buf = self.buf }
        )
        or vim.api.nvim_get_option_value('readonly', { buf = self.buf })
    end,
    hl = { fg = 'unmodifiable_fg' },
    provider = ' 󰌾',
  },
}

-- Statusline components.
local ModeBar = {
  hl = function(self)
    return { fg = self.colour }
  end,
  provider = '█',
}

local ModeText = {
  static = {
    names = {
      n = 'NORMAL',
      no = 'O-PENDING',
      nov = 'O-PENDING',
      noV = 'O-PENDING',
      ['no\x16'] = 'O-PENDING',
      niI = 'NORMAL',
      niR = 'NORMAL',
      niV = 'NORMAL',
      nt = 'NORMAL',
      ntT = 'NORMAL',
      v = 'VISUAL',
      vs = 'VISUAL',
      V = 'V-LINE',
      Vs = 'V-LINE',
      ['\x16'] = 'V-BLOCK',
      ['\x16s'] = 'V-BLOCK',
      s = 'SELECT',
      S = 'S-LINE',
      ['\x13'] = 'S-BLOCK',
      i = 'INSERT',
      ic = 'INSERT',
      ix = 'INSERT',
      R = 'REPLACE',
      Rc = 'REPLACE',
      Rx = 'REPLACE',
      Rv = 'V-REPLACE',
      Rvc = 'V-REPLACE',
      Rvx = 'V-REPLACE',
      c = 'COMMAND',
      cv = 'EX',
      ce = 'EX',
      r = 'REPLACE',
      rm = 'MORE',
      ['r?'] = 'CONFIRM',
      ['!'] = 'SHELL',
      t = 'TERMINAL',
    },
  },
  flexible = priorities.low,
  hl = function(self)
    return { fg = self.colour, bold = true }
  end,
  -- If there is enough space, display the full mode text with padding.
  {
    provider = function(self)
      return ' %9(' .. self.names[self.mode] .. '%)'
    end,
  },
  -- Fall back to full mode text with no padding.
  {
    provider = function(self)
      return ' ' .. self.names[self.mode]
    end,
  },
  -- Fall back to the first character of the mode text.
  {
    provider = function(self)
      return ' ' .. self.names[self.mode]:sub(1, 1)
    end,
  },
  -- Fall back to nothing.
  Empty,
}

local ModeIndicatorLeft =
  hutils.insert(ModeData, pad_right({ ModeBar, ModeText }))

local MacroRec = {
  condition = function(self)
    self.reg = vim.fn.reg_recording()
    return self.reg ~= ''
  end,
  flexible = priorities.high,
  pad_symmetric({
    { hl = { fg = 'macro_rec' }, provider = ' [' },
    {
      hl = { fg = 'macro_reg' },
      provider = function()
        return vim.fn.reg_recording()
      end,
    },
    { hl = { fg = 'macro_rec' }, provider = ']' },
  }),
  pad_symmetric({ hl = { fg = 'macro_rec' }, provider = '' }),
}

local GitBranch = hutils.insert(GitData, {
  hl = { fg = 'git_branch' },
  pad_symmetric({
    flexible = priorities.medium,
    -- If there is enough space, display the full branch name.
    {
      provider = function(self)
        local branch = self.status_dict.head

        if branch == nil or branch == '' then
          branch = '[Detached]'
        end

        return '  ' .. branch .. ' '
      end,
    },
    -- Fall back to just an icon.
    { provider = '  ' },
  }),
})

local BufferNameHead = {
  flexible = priorities.low,
  hl = { fg = 'dir_fg' },
  -- If there is enough space, display the full buffer name head.
  {
    provider = function(self)
      local trail = self.bufhead:sub(-1) == '/' and '' or '/'
      return escape(self.bufhead) .. trail
    end,
  },
  -- Fall back to a shortened buffer name head.
  {
    provider = function(self)
      local short_dir = vim.fn.pathshorten(self.bufhead)
      local trail = short_dir:sub(-1) == '/' and '' or '/'

      return escape(short_dir) .. trail
    end,
  },
  -- Fall back to nothing.
  Empty,
}

local BufferFull = pad_symmetric({
  BufferIcon,
  BufferNameHead,
  BufferNameTail,
  BufferFlags,
})

local Position = {
  flexible = priorities.low,
  -- If there is enough space, display line, total lines, and column.
  pad_symmetric({ provider = '%21(Ln %l of %L, Col %c%)' }),
  -- Fall back to the same information without words.
  pad_symmetric({ provider = '%10(%l/%L:%c%)' }),
  -- Fall back to just line and column.
  pad_symmetric({ provider = '%6(%l:%c%)' }),
  -- Fall back to nothing.
  Empty,
}

local Scrollbar = {
  flexible = priorities.low,
  -- If there is enough space, display a percentage and scroll bar.
  pad_symmetric({
    { provider = '%P ' },
    {
      static = {
        sbar = { '🭶', '🭷', '🭸', '🭹', '🭺', '🭻' },
      },
      hl = { fg = 'scrollbar_fg', bg = 'scrollbar_bg' },
      provider = function(self)
        local curr_line = vim.api.nvim_win_get_cursor(self.win)[1]
        local lines = vim.api.nvim_buf_line_count(self.buf)
        local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1

        return string.rep(self.sbar[i], 2)
      end,
    },
  }),
  -- Fall back to just a percentage.
  pad_symmetric({ provider = '%P' }),
  -- Fall back to nothing.
  Empty,
}

local ModeBarLeft = hutils.insert(ModeData, pad_right(ModeBar))
local ModeBarRight = hutils.insert(ModeData, pad_left(ModeBar))

local ActiveStatusLine = hutils.insert(
  WinData,
  ModeIndicatorLeft,
  MacroRec,
  GitBranch,
  Trunc,
  BufferFull,
  Align,
  Position,
  Scrollbar,
  ModeBarRight
)

local InactiveStatusLine = hutils.insert(WinData, {
  hl = {
    fg = 'statusline_inactive_fg',
    bg = 'statusline_inactive_bg',
    force = true,
  },
  ModeBarLeft,
  Trunc,
  BufferFull,
  Align,
  Position,
  ModeBarRight,
})

-- Window bar components.
local BreadcrumbsUnknown = { provider = '[Unknown]' }

--- Creates a breadcrumbs directory component.
---
--- @param name string Directory name.
--- @return table component Breadcrumbs component for that directory.
local function breadcrumbs_dir(name)
  local icon, hl = micons.get('directory', name)
  local spacer = icon == '' and '' or ' '

  if name == '' then
    return {
      hl = { fg = 'breadcrumbs_dir_fg' },
      BreadcrumbsUnknown,
    }
  end

  return {
    {
      provider = icon .. spacer,
      hl = { fg = hutils.get_highlight(hl).fg },
    },
    {
      hl = { fg = 'breadcrumbs_dir_fg' },
      provider = escape(name),
    },
  }
end

--- Creates a breadcrumbs symbol component using Aerial.
---
--- @param symbol table Aerial symbol.
--- @return table component Breadcrumbs component for that symbol.
local function breadcrumbs_symbol(symbol)
  local icon = symbol.icon or ''
  local name = symbol.name or ''

  if name == '' then
    return BreadcrumbsUnknown
  end

  local spacer = icon == '' and '' or ' '

  local kind

  if type(symbol.kind) == 'string' then
    kind = symbol.kind
  elseif type(symbol.kind) == 'number' then
    kind = vim.lsp.protocol.SymbolKind[symbol.kind] or 'Unknown'
  end

  return {
    {
      provider = icon .. spacer,
      hl = { fg = hutils.get_highlight('Aerial' .. kind .. 'Icon').fg },
    },
    {
      provider = escape(name),
      hl = { fg = hutils.get_highlight('Aerial' .. kind).fg },
    },
  }
end

local BreadcrumbsLeft = pad_right({
  init = function(self)
    local BreadcrumbsSep = { provider = ' ' .. icons.arrows.right .. ' ' }
    local children = {}

    -- Construct directory components.
    for symbol in string.gmatch(self.bufhead, '([^/]+)') do
      children[#children + 1] = breadcrumbs_dir(symbol)
    end

    children[#children + 1] = { BufferIcon, BufferNameTail, BufferFlags }

    -- Construct symbol components.
    for _, symbol in ipairs(aerial.get_location(true)) do
      children[#children + 1] = breadcrumbs_symbol(symbol)
    end

    children = join(children, BreadcrumbsSep)
    self.child = self:new(children, 1)
  end,
  provider = function(self)
    return ' ' .. self.child:eval()
  end,
})

local LSPClients = {
  condition = function(self)
    self.clients = vim.lsp.get_clients({ bufnr = self.buf })
    return #self.clients > 0
  end,
  init = function(self)
    self.names = {}

    for _, client in ipairs(self.clients) do
      self.names[#self.names + 1] = client.name
    end
  end,
  pad_symmetric({
    flexible = priorities.medium,
    -- If there is enough space, display an icon and active clients.
    {
      provider = function(self)
        return ' ' .. table.concat(self.names, ', ')
      end,
    },
    -- Fall back to just an icon.
    { provider = '' },
  }),
}

--- Creates a diagnostic component.
---
--- @param name string Diagnostic name.
--- @param count integer Diagnostic count.
--- @return table component Component for the diagnostic.
local function diagnostic(name, count)
  local severity = vim.diagnostic.severity[name:upper()]
  local icon = vim.diagnostic.config().signs.text[severity]

  return {
    flexible = priorities.high,
    -- If there is enough space, display the diagnostic icon and number.
    {
      hl = { fg = 'diagnostics_' .. name },
      provider = icon .. ' ' .. tostring(count),
    },
    -- Fall back to just the diagnostic number.
    {
      hl = { fg = 'diagnostics_' .. name },
      provider = tostring(count),
    },
  }
end

local Diagnostics = {
  static = {
    names = { 'error', 'warn', 'info', 'hint' },
  },
  condition = function(self)
    self.counts = vim.diagnostic.count(self.buf)
    return next(self.counts) ~= nil
  end,
  init = function(self)
    local children = {}

    for _, name in ipairs(self.names) do
      local severity = vim.diagnostic.severity[name:upper()]
      local count = self.counts[severity] or 0

      if count > 0 then
        children[#children + 1] = diagnostic(name, count)
      end
    end

    self.child = self:new(join(children, InertSpace), 1)
  end,
  pad_symmetric({
    provider = function(self)
      return self.child:eval()
    end,
  }),
}

--- Creates a Git diff component.
---
--- @param name string Git diff name.
--- @param count integer Git diff count.
--- @return table component Component for the diff.
local function git_diff(name, count)
  return {
    hl = { fg = 'git_' .. name },
    flexible = priorities.medium,
    -- If there is enough space, display the diff icon and number.
    {
      provider = function(self)
        return self.icons[name] .. ' ' .. tostring(count)
      end,
    },
    -- Fall back to just the diff number.
    { provider = tostring(count) },
  }
end

local GitDiffs = hutils.insert(GitData, {
  static = {
    names = { 'added', 'removed', 'changed' },
    icons = { added = '', removed = '', changed = '' },
  },
  condition = function(self)
    for _, name in ipairs(self.names) do
      if (self.status_dict[name] or 0) > 0 then
        return true
      end
    end

    return false
  end,
  init = function(self)
    local children = {}

    for _, name in ipairs(self.names) do
      local count = self.status_dict[name] or 0

      if count > 0 then
        children[#children + 1] = git_diff(name, count)
      end
    end

    children = join(children, InertSpace)
    table.insert(children, 1, InertSpace)
    children[#children + 1] = InertSpace

    self.child = self:new(children, 1)
  end,
  pad_symmetric({
    provider = function(self)
      return self.child:eval()
    end,
  }),
})

local WindowCloseButtonRight = pad_left({
  {
    on_click = {
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_win_close(minwid, false)
        end)
      end,
      minwid = function(self)
        return self.win
      end,
      name = 'window_close_callback',
    },
    provider = '',
  },
  InertSpace,
})

local ActiveWinbar = hutils.insert(
  WinData,
  BreadcrumbsLeft,
  Align,
  LSPClients,
  Diagnostics,
  GitDiffs,
  WindowCloseButtonRight
)

local InactiveWinbar = hutils.insert(WinData, {
  hl = { fg = 'winbar_inactive_fg', bg = 'winbar_inactive_bg', force = true },
  BreadcrumbsLeft,
  Align,
  LSPClients,
  Diagnostics,
  GitDiffs,
  WindowCloseButtonRight,
})

-- Tab pages line components.
local ModeTabline = hutils.insert(ModeData, {
  {
    hl = function(self)
      return { fg = 'black', bg = self.colour }
    end,
    provider = '  ',
  },
  InertSpace,
})

local BufferNumber = {
  provider = function(self)
    return ' ' .. tostring(self.buf) .. ' '
  end,
}

local BufferButton = {
  on_click = {
    callback = function(_, minwid, _, button)
      -- Delete the buffer on a middle mouse click. Otherwise, set the current
      -- window buffer to the clicked buffer.
      if button == 'm' then
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
    name = 'buffer_callback',
  },
  BufferNumber,
  BufferIcon,
  BufferNameTail,
  BufferFlags,
}

local BufferCloseButton = {
  condition = function(self)
    return not vim.api.nvim_get_option_value('modified', { buf = self.buf })
  end,
  InertSpace,
  {
    on_click = {
      -- Delete the buffer on clicking.
      callback = function(_, minwid)
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      end,
      minwid = function(self)
        return self.bufnr
      end,
      name = 'buffer_close_callback',
    },
    { provider = '' },
  },
  InertSpace,
}

local Buffer = {
  init = function(self)
    self.buf = self.bufnr or 0
    self.buftail = vim.fs.basename(vim.api.nvim_buf_get_name(self.buf))
    self.filetype =
      vim.api.nvim_get_option_value('filetype', { buf = self.buf })
  end,
  -- Highlight the active buffer and force dimming of inactive buffers.
  hl = function(self)
    if self.is_active then
      return { fg = 'buffer_active_fg', bg = 'buffer_active_bg', force = true }
    else
      return {
        fg = 'buffer_inactive_fg',
        bg = 'buffer_inactive_bg',
        force = true,
      }
    end
  end,
  BufferButton,
  BufferCloseButton,
}

local BuffersLeft = pad_right(hutils.make_buflist(Buffer))

local TabDecorator = {
  hl = { fg = 'tab_active_highlight' },
  -- Highlight active tabs with a bright line.
  provider = function(self)
    if self.is_active then
      return '▎'
    end

    return ' '
  end,
}

local TabButton = {
  hl = { fg = 'tab_active_highlight' },
  provider = function(self)
    return '%' .. self.tabnr .. 'T' .. self.tabpage .. ' %T'
  end,
}

local TabCloseButton = {
  {
    provider = function(self)
      return '%' .. self.tabnr .. 'X%X'
    end,
  },
  InertSpace,
}

local Tab = {
  hl = function(self)
    if self.is_active then
      return { fg = 'tab_active_fg', bg = 'tab_active_bg' }
    else
      return { fg = 'tab_inactive_fg', bg = 'tab_inactive_bg', force = true }
    end
  end,
  TabDecorator,
  TabButton,
  TabCloseButton,
}

local TabsRight = pad_left({
  condition = function()
    return #vim.api.nvim_list_tabpages() > 1
  end,
  hutils.make_tablist(Tab),
})

local Tabline = {
  ModeTabline,
  Trunc,
  BuffersLeft,
  Align,
  TabsRight,
}

-- Statuscolumn components.
local Signcolumn = { provider = '%s' }

local Numbercolumn = {
  condition = function(self)
    return vim.api.nvim_get_option_value('number', { win = self.win })
      or vim.api.nvim_get_option_value('relativenumber', { win = self.win })
  end,
  provider = '%l ',
}

local Foldcolumn = {
  -- Hide the foldcolumn on virtual lines since fold indicators duplicate on
  -- virtual lines.
  condition = function(self)
    return vim.api.nvim_get_option_value('foldenable', { win = self.win })
      and vim.api.nvim_get_option_value('foldcolumn', { win = self.win }) ~= '0'
      and vim.v.virtnum == 0
  end,
  provider = '%C ',
}

local Statuscolumn = {
  condition = function(self)
    self.win = vim.fn.win_getid(self.winnr)

    if not vim.api.nvim_win_is_valid(self.win) then
      return false
    end

    return utils.valid_normal_disk_buf(vim.api.nvim_win_get_buf(self.win))
  end,
  InertSpace,
  Signcolumn,
  Numbercolumn,
  Foldcolumn,
}

require('heirline').setup({
  opts = {
    disable_winbar_cb = function(ev)
      return not utils.valid_normal_disk_buf(ev.buf)
    end,
    colors = get_colours,
  },
  statusline = active_inactive_win_component(
    ActiveStatusLine,
    InactiveStatusLine
  ),
  winbar = active_inactive_win_component(ActiveWinbar, InactiveWinbar),
  tabline = Tabline,
  statuscolumn = Statuscolumn,
})

-- Schedules redrawing of statusline, window bar, and tab pages line.
--
-- This is called on specific events to prevent a stale statusline.
local redraw = vim.schedule_wrap(function()
  vim.cmd.redrawstatus({ bang = true })
  vim.cmd.redrawtabline()
end)

-- Re-initializes the window bar.
--
-- This is called on specific events when a re-evaluation of whether the window
-- bar needs to be displayed should occur.
local reinit_winbar = vim.schedule_wrap(function()
  vim.api.nvim_exec_autocmds('BufWinEnter', {
    group = 'Heirline_init_winbar',
    buffer = vim.api.nvim_get_current_buf(),
  })
end)

local heirline_update_group =
  vim.api.nvim_create_augroup('HeirlineUpdate', { clear = true })

-- Redraw on these events.
vim.api.nvim_create_autocmd({
  'ModeChanged',
  'DiagnosticChanged',
  'LspAttach',
  'LspDetach',
  'TermLeave',
}, {
  callback = redraw,
  group = heirline_update_group,
})

vim.api.nvim_create_autocmd('User', {
  callback = redraw,
  pattern = 'GitSignsUpdate',
  group = heirline_update_group,
})

-- Re-evaluate displaying of the window bar on these events.
vim.api.nvim_create_autocmd('BufWritePost', {
  callback = reinit_winbar,
  group = heirline_update_group,
})

vim.api.nvim_create_autocmd('UIEnter', {
  callback = function()
    if vim.v.startreason == 'restart' or vim.v.startreason == 'restart!' then
      reinit_winbar()
    end
  end,
  group = heirline_update_group,
})

-- Update highlights on colour scheme change
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    hutils.on_colorscheme(get_colours)
  end,
  group = heirline_update_group,
})

-- Show tab pages line only if there are listed buffers that are not visible.
vim.api.nvim_create_autocmd({
  'BufAdd',
  'BufDelete',
  'BufEnter',
  'BufWinEnter',
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
        break
      end
    end

    vim.o.showtabline = not all_bufs_visible and 2 or 1
  end),
  group = heirline_update_group,
})
