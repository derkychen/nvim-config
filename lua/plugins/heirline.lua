local utils = require("utils")

return {
  "rebelot/heirline.nvim",
  config = function()
    local hconds = require("heirline.conditions")
    local hutils = require("heirline.utils")

    -- Flexible component priorities
    local priorities = {
      Pad = 7,
      ModeText = 2,
      GitBranch = 5,
      GitDiff = 5,
      Diagnostic = 5,
      FileDir = 1,
      LspActive = 6,
      NavPosition = 4,
      NavPercentage = 3,
    }

    -- Common components
    local function Space(num)
      return { provider = string.rep(" ", num or 1) }
    end
    local HalfPad = {
      hl = { bg = "none" },
      flexible = priorities.Pad,
      Space(2),
      Space(),
    }
    local Trunc = { provider = "%<" }
    local Align = { provider = "%=" }
    local Bar = { provider = "█" }

    -- Pad leftmost components on the right
    local function pad_right(component)
      return {
        condition = component.condition,
        component,
        HalfPad,
      }
    end

    -- Pad rightmost components on the left
    local function pad_left(component)
      return {
        condition = component.condition,
        HalfPad,
        component,
      }
    end

    -- Pad middle components symmetrically
    local function pad_symmetric(component)
      return {
        condition = component.condition,
        HalfPad,
        component,
        HalfPad,
      }
    end

    -- Combine active and inactive window versions of component
    local function active_inactive_component(active, inactive)
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
      local function get_hl(name, get_bg)
        get_bg = get_bg or false
        local fallback_fg = hutils.get_highlight("Normal").fg
        local fallback_bg = hutils.get_highlight("Normal").bg
        local hl
        if get_bg then
          hl = hutils.get_highlight(name).bg or fallback_bg
        else
          hl = hutils.get_highlight(name).fg or fallback_fg
        end
        return hl
      end
      return {
        normal = get_hl("Function"),
        insert = get_hl("Character"),
        visual = get_hl("Conditional"),
        command = get_hl("@variable.parameter"),
        replace = get_hl("@variable.builtin"),
        terminal = get_hl("@property"),
        bright_fg = get_hl("Folded"),
        bright_bg = get_hl("Folded", true),
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
        close = get_hl("@variable.builtin"),
        buffer_bufnr = get_hl("Function"),
        buffer_active_fg = get_hl("TablineFill"),
        buffer_active_bg = get_hl("Folded", true),
        buffer_inactive_fg = get_hl("Tabline"),
        buffer_inactive_bg = get_hl("Tabline", true),
        tab_active_fg = get_hl("TablineSel"),
        tab_active_bg = get_hl("TablineSel", true),
        tab_inactive_fg = get_hl("Tabline"),
        tab_inactive_bg = get_hl("Tabline", true),
        inactive_fg = get_hl("StatusLineNC"),
        inactive_bg = get_hl("StatusLineNC", true),
      }
    end

    -- Parent component that stores window-local information
    local WinInfo = {
      init = function(self)
        self.winid = vim.fn.win_getid(self.winnr)
        self.buf = vim.api.nvim_win_get_buf(self.winid)
        self.winrelpath = vim.fn.expand("%:~:.")
        self.winreldir = vim.fn.fnamemodify(self.winrelpath, ":h")
        self.filename = vim.fn.fnamemodify(self.winrelpath, ":t")
        self.filetype = vim.bo[self.buf].filetype
      end,
    }

    -- Parent component that stores mode information
    local Mode = {
      static = {
        colors = {
          n       = "normal",
          i       = "insert",
          v       = "visual",
          V       = "visual",
          ["\22"] = "visual",
          c       = "command",
          s       = "visual",
          S       = "visual",
          ["\19"] = "visual",
          R       = "replace",
          r       = "replace",
          ["!"]   = "terminal",
          t       = "terminal",
        },
      },
      init = function(self)
        self.mode = vim.fn.mode(1)
        self.color = self.colors[self.mode:sub(1, 1)]
      end,
    }

    local ModeBar = {
      hl = function(self) return { fg = self.color } end,
      Bar,
    }

    local ModeText = {
      static = {
        names = {
          n         = "NORMAL",
          no        = "O-PENDING",
          nov       = "O-PENDING",
          noV       = "O-PENDING",
          ["no\22"] = "O-PENDING",
          niI       = "NORMAL",
          niR       = "NORMAL",
          niV       = "NORMAL",
          nt        = "NORMAL",
          ntT       = "NORMAL",
          v         = "VISUAL",
          vs        = "VISUAL",
          V         = "V-LINE",
          Vs        = "V-LINE",
          ["\22"]   = "V-BLOCK",
          ["\22s"]  = "V-BLOCK",
          s         = "SELECT",
          S         = "S-LINE",
          ["\19"]   = "S-BLOCK",
          i         = "INSERT",
          ic        = "INSERT",
          ix        = "INSERT",
          R         = "REPLACE",
          Rc        = "REPLACE",
          Rx        = "REPLACE",
          Rv        = "V-REPLACE",
          Rvc       = "V-REPLACE",
          Rvx       = "V-REPLACE",
          c         = "COMMAND",
          cv        = "EX",
          ce        = "EX",
          r         = "REPLACE",
          rm        = "MORE",
          ["r?"]    = "CONFIRM",
          ["!"]     = "SHELL",
          t         = "TERMINAL",
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
        Space(),
        {
          provider = function(self)
            return "%9(" .. self.names[self.mode] .. "%)"
          end,
        },
      },
      {
        Space(),
        {
          provider = function(self)
            return self.names[self.mode]
          end,
        },
      },
      {
        Space(),
        {
          provider = function(self)
            return string.sub(self.names[self.mode], 1, 1)
          end,
        },
      },
      { provider = "" },
    }

    local Git = {
      condition = hconds.is_git_repo,
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
      end,
      hl = { bg = "bright_bg" },
    }

    local GitBranch = {
      flexible = priorities.GitBranch,
      hl = { fg = "git_branch" },
      {
        Space(),
        {
          provider = function(self)
            local branch = self.status_dict.head
            if branch == nil or branch == "" then
              branch = "master"
            end
            return " " .. branch
          end,
        },
        Space(),
      },
      {
        Space(),
        { provider = "" },
        Space(),
      },
    }

    local function GitDiff(type)
      return {
        static = {
          icons = {
            added = "",
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
          { provider = function(self) return self.icons[type] end },
          Space(),
          { provider = function(self) return self.count end },
          Space(),
        },
        {
          { provider = function(self) return self.count end },
          Space(),
        },
      }
    end

    local GitDiffs = {
      condition = function(self)
        return self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      end,
      {
        GitDiff("added"),
        GitDiff("removed"),
        GitDiff("changed"),
      },
    }

    local function Diagnostic(type, last)
      local spacer
      last = last or false
      if last then spacer = nil else spacer = Space() end
      local icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity[string.upper(type)]]
      return {
        condition = function(self)
          self.count = self.c[vim.diagnostic.severity[string.upper(type)]] or 0
          return self.count > 0
        end,
        flexible = priorities.Diagnostic,
        {
          {
            provider = function(self)
              return (icon .. " " .. self.count)
            end,
            hl = { fg = "diag_" .. type },
          },
          spacer,
        },
        {
          {
            provider = function(self)
              return self.count
            end,
            hl = { fg = "diag_" .. type },
          },
          spacer,
        },
      }
    end

    local Diagnostics = {
      condition = hconds.has_diagnostics,
      init = function(self)
        self.c = vim.diagnostic.count(self.buf)
      end,
      pad_symmetric({
        Diagnostic("error"),
        Diagnostic("warn"),
        Diagnostic("info"),
        Diagnostic("hint", true),
      }),
    }

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
        Space(),
      },
      {
        {
          provider = function(self)
            local short_dir = vim.fn.pathshorten(self.winreldir)
            local trail = short_dir:sub(-1) == "/" and "" or "/"
            return short_dir .. trail
          end,
        },
        Space(),
      },
      { provider = "" },
    }

    local FileIcon = {
      init = function(self)
        local get_icon = require("mini.icons").get
        local is_default = false
        self.icon, self.hl, is_default = get_icon("file", self.filename)
        if is_default then self.icon, self.hl = get_icon("filetype", self.filetype) end
      end,
      hl = function(self)
        return { fg = hutils.get_highlight(self.hl).fg }
      end,
      {
        provider = function(self)
          return self.icon
        end,
      },
      Space(),
    }

    local FileName = {
      provider = function(self)
        local filename = self.filename
        if filename == "" then return "[No Name]" end
        return filename
      end,
    }

    local FileFlags = {
      {
        condition = function(self)
          return vim.bo[self.buf].modified
        end,
        {
          Space(),
          {
            provider = "[+]",
            hl = { fg = "flag_fg" },
          },
        },
      },
      {
        condition = function(self)
          return not vim.bo[self.buf].modifiable or vim.bo[self.buf].readonly
        end,
        {
          Space(),
          {
            provider = "",
            hl = { fg = "dimmed_fg" },
          },
        },
      },
    }

    local LspActive = {
      condition = hconds.lsp_attached,
      {
        flexible = priorities.LspActive,
        pad_symmetric({
          provider = function(self)
            local names = {}
            for _, server in pairs(vim.lsp.get_clients({ bufnr = self.buf })) do
              table.insert(names, server.name)
            end
            return " " .. table.concat(names, ", ")
          end,
        }),
        pad_symmetric({ provider = "" }),
        { provider = "" },
      },
    }

    local Nav = {}

    local NavPosition = {
      flexible = priorities.NavPosition,
      pad_symmetric({ provider = "%10(%l/%L:%c%)" }),
      pad_symmetric({ provider = "%6(%l:%c%)" }),
      { provider = "" },
    }

    local NavPercentage = {
      flexible = priorities.NavPercentage,
      pad_symmetric({
        { provider = "%P" },
        Space(),
        {
          static = {
            sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" }
          },
          provider = function(self)
            local curr_line = vim.api.nvim_win_get_cursor(self.winid)[1]
            local lines = vim.api.nvim_buf_line_count(self.buf)
            local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
            return string.rep(self.sbar[i], 2)
          end,
          hl = { fg = "bright_fg", bg = "bright_bg" },
        },
      }),
      pad_symmetric({ provider = "%P" }),
      { provider = "" },
    }

    local BreadcrumbsSep = { provider = "" }

    local function BreadcrumbsDirItem(name)
      local get_icon = require("mini.icons").get
      local spacer
      local icon, hl
      icon, hl, _ = get_icon("directory", name)
      if icon == "" then spacer = nil else spacer = Space() end
      if name ~= "" then
        return {
          Space(),
          {
            provider = icon,
            hl = { fg = hutils.get_highlight(hl).fg },
          },
          spacer,
          {
            provider = name,
          },
          Space(),
        }
      end
    end

    local BreadcrumbsPath = {
      init = function(self)
        local children = {}
        local dirs = {}
        for dir in string.gmatch(self.winreldir, "([^/]+)") do
          table.insert(dirs, dir)
        end
        for _, name in ipairs(dirs) do
          table.insert(children, BreadcrumbsDirItem(name))
          table.insert(children, BreadcrumbsSep)
        end
        table.insert(children, {
          Space(),
          FileIcon,
          FileName,
          Space(),
        })
        self.child = self:new(children, 1)
      end,
      provider = function(self)
        return self.child:eval()
      end,
    }

    local function BreadcrumbsAerialItem(symbol)
      local spacer
      local icon = symbol.icon or ""
      local name = symbol.name or ""
      if icon == "" then spacer = nil else spacer = Space() end
      local kind
      if type(symbol.kind) == "string" then
        kind = symbol.kind
      elseif type(symbol.kind) == "number" then
        kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown"
      end
      if name ~= "" then
        return {
          Space(),
          {
            provider = icon,
            hl = { fg = hutils.get_highlight("Aerial" .. kind .. "Icon").fg },
          },
          spacer,
          {
            provider = name,
            hl = { fg = hutils.get_highlight("Aerial" .. kind).fg },
          },
          Space(),
        }
      end
    end

    local BreadcrumbsAerial = {
      condition = function()
        local ok, aerial = pcall(require, "aerial")
        if not ok then return false end
        local loc = aerial.get_location(true)
        return loc and not vim.tbl_isempty(loc)
      end,
      init = function(self)
        local symbols = require("aerial").get_location(true) or {}
        local children = {}
        for _, symbol in ipairs(symbols) do
          table.insert(children, { BreadcrumbsSep, BreadcrumbsAerialItem(symbol) })
        end
        self.child = self:new(children, 1)
      end,
      provider = function(self)
        return self.child:eval()
      end,
    }

    local FileBufnr = {
      {
        hl = { fg = "buffer_bufnr" },
        provider = function(self)
          return tostring(self.buf)
        end,
      },
      Space(2),
    }

    local BufferFile = {
      on_click = {
        callback = function(_, minwid, _, button)
          if (button == "m") then
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
      FileFlags
    }

    local BufferCloseButton = {
      condition = function(self)
        return not vim.api.nvim_get_option_value("modified", { buf = self.buf })
      end,
      Space(2),
      {
        provider = "",
        hl = { fg = "close" },
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
      },
    }

    local Buffer = {
      init = function(self)
        self.buf = self.bufnr or 0
        self.filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":t")
        self.filetype = vim.bo[self.buf].filetype
      end,
      Space(),
      {
        hl = function(self)
          if self.is_active then
            return { fg = "buffer_active_fg", bg = "buffer_active_bg" }
          else
            return { fg = "buffer_inactive_fg", bg = "buffer_inactive_bg", force = true }
          end
        end,
        Space(),
        BufferFile,
        BufferCloseButton,
        Space(),
      },
    }

    local Nvim = {
      hl = function(self)
        return { fg = "black", bg = self.color }
      end,
      provider = "",
    }

    local TabNumber = {
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
      end,
    }

    local TabCloseButton = {
      provider = function(self)
        return "%" .. self.tabnr .. "X%X"
      end,
    }

    local Tab = {
      Space(),
      {
        hl = function(self)
          if self.is_active then
            return { fg = "tab_active_fg", bg = "tab_active_bg" }
          else
            return { fg = "tab_inactive_fg", bg = "tab_inactive_bg", force = true }
          end
        end,
        TabNumber,
        TabCloseButton,
        Space(),
      },
    }

    local SignColumn = { provider = "%s" }

    local NumberColumn = {
      condition = function(self) return vim.wo[self.winid].number or vim.wo[self.winid].relativenumber end,
      { provider = "%l" },
      Space(),
    }

    local FoldColumn = {
      condition = function(self) return vim.wo[self.winid].foldenable and vim.wo[self.winid].foldcolumn ~= "0" and
        vim.v.virtnum == 0 end,
      { provider = "%C" },
      Space(),
    }

    local ModeIndicatorLeft = pad_right(hutils.insert(Mode,
      ModeBar,
      ModeText
    ))

    Git = pad_symmetric(hutils.insert(Git,
      GitBranch,
      GitDiffs
    ))

    local StatuslineFile = pad_symmetric({
      FileDir,
      FileIcon,
      FileName,
      FileFlags
    })

    Nav = hutils.insert(Nav,
      NavPosition,
      NavPercentage
    )

    local ModeBarRight = pad_left(hutils.insert(Mode,
      ModeBar
    ))

    local Breadcrumbs = { BreadcrumbsPath, BreadcrumbsAerial }

    local ModeNvim = hutils.insert(Mode,
      ModeBar,
      Nvim,
      ModeBar
    )

    local Buffers = hutils.make_buflist(Buffer)

    local Tabs = {
      condition = function()
        return #vim.api.nvim_list_tabpages() > 1
      end,
      hutils.make_tablist(Tab),
    }

    local ActiveStatusline = hutils.insert(WinInfo, {
      ModeIndicatorLeft,
      Git,
      Diagnostics,
      Trunc,
      StatuslineFile,
      Align,
      LspActive,
      Nav,
      ModeBarRight,
    })

    local InactiveStatusline = hutils.insert(WinInfo, {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      pad_right(Bar),
      Trunc,
      StatuslineFile,
      Align,
      Nav,
      pad_left(Bar),
    })

    local ActiveWinbar = hutils.insert(WinInfo, {
      Breadcrumbs,
      Align,
    })

    local InactiveWinbar = hutils.insert(WinInfo, {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      Breadcrumbs,
      Align,
    })

    local Tabline = {
      callback = function()
        return #vim.api.nvim_list_bufs() > 1 or #vim.api.nvim_list_tabpages() > 1
      end,
      ModeNvim,
      Trunc,
      Buffers,
      Align,
      pad_left(Tabs),
    }

    local StatusColumn = hutils.insert(WinInfo, {
      condition = function(self)
        return utils.valid_normal_buf(self.buf)
      end,
      Space(),
      SignColumn,
      NumberColumn,
      FoldColumn,
    })

    require("heirline").setup({
      opts = {
        disable_winbar_cb = function(ev)
          local buf = ev.buf
          local bufname = vim.api.nvim_buf_get_name(buf)
          return not (utils.valid_normal_buf(buf) and vim.uv.fs_stat(bufname))
        end,
        colors = get_colors,
      },
      statusline = active_inactive_component(ActiveStatusline, InactiveStatusline),
      winbar = active_inactive_component(ActiveWinbar, InactiveWinbar),
      tabline = Tabline,
      statuscolumn = StatusColumn,
    })

    -- Redraw statusline and tabline on mode change to prevent delay
    vim.api.nvim_create_autocmd("ModeChanged", {
      callback = vim.schedule_wrap(function()
        vim.cmd.redrawstatus()
        vim.cmd.redrawtabline()
      end)
    })

    -- Update colors on colorscheme change
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        hutils.on_colorscheme(get_colors)
      end,
    })

    -- Show tabline based on if there are listed buffers other than the active one
    vim.api.nvim_create_autocmd({
      "BufAdd",
      "BufDelete",
      "BufEnter",
      "BufWinEnter",
    }, {
      callback = vim.schedule_wrap(function()
        local num_bufs = #vim.fn.getbufinfo({ buflisted = 1 }) + (not vim.bo.buflisted and 1 or 0)
        vim.opt.showtabline = num_bufs > 1 and 2 or 1
      end)
    })
  end,
}
