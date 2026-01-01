return {
  "rebelot/heirline.nvim",
  config = function()
    local conditions = require("heirline.conditions")
    local utils = require("heirline.utils")

    -- Flexible component priorities
    local priorities = {
      FileDir = 1,
      GitBranch = 2,
      ModeText = 3,
    }

    -- Colors
    local function get_colors()
      local function get_hl(name, get_bg)
        get_bg = get_bg or false

        local fallback_fg = utils.get_highlight("Normal").fg
        local fallback_bg = utils.get_highlight("Normal").bg

        local hl
        if get_bg then
          hl = utils.get_highlight(name).bg or fallback_bg
        else
          hl = utils.get_highlight(name).fg or fallback_fg
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
        git_added = get_hl("@property"),
        git_removed = get_hl("@variable.builtin"),
        git_changed = get_hl("Function"),
        diag_error = get_hl("DiagnosticError"),
        diag_warn = get_hl("DiagnosticWarn"),
        diag_info = get_hl("DiagnosticInfo"),
        diag_hint = get_hl("DiagnosticHint"),
        dimmed_fg = get_hl("SpecialKey"),
        winbar_bg = get_hl("CursorLine", true),
        flag_fg = get_hl("@variable.parameter"),
        close = get_hl("@variable.builtin"),
        buffer_bufnr = get_hl("Function"),
        buffer_active_fg = get_hl("Normal"),
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

    -- Spacing
    local Space = setmetatable({ provider = " " }, {
      __call = function(_, num)
        return { provider = string.rep(" ", num or 1) }
      end,
    })
    local Pad = { provider = "    ", hl = { bg = "none" } }
    local Align = { provider = "%=" }

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
      provider = "█",
      hl = function(self) return { fg = self.color } end,
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
      { provider = "" },
    }

    local Git = {
      condition = conditions.is_git_repo,
      init = function(self)
        self.status_dict = vim.b.gitsigns_status_dict
      end,
      hl = { bg = "bright_bg" },
    }

    local GitBranch = {
      flexible = priorities.GitBranch,
      hl = { fg = "git_branch" },
      {
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
      },
      {
        Space,
        { provider = "" },
        Space,
      },
    }

    local function GitDiff(icon, type)
      return {
        condition = function(self)
          self.count = self.status_dict[type] or 0
          return self.count > 0
        end,
        {
          hl = { fg = "git_" .. type },
          { provider = icon },
          Space,
          { provider = function(self) return self.count end },
          Space,
        },
      }
    end

    local GitDiffs = {
      condition = function(self)
        return self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
      end,
      {
        GitDiff("", "added"),
        GitDiff("", "removed"),
        GitDiff("󰜥", "changed"),
      },
    }

    local function Diagnostic(type, last)
      local spacer
      last = last or false
      if last then spacer = nil else spacer = Space end
      local icon = vim.diagnostic.config().signs.text[vim.diagnostic.severity[string.upper(type)]]
      return {
        condition = function(self)
          self.count = self.c[vim.diagnostic.severity[string.upper(type)]] or 0
          return self.count > 0
        end,
        {
          {
            provider = function(self)
              return (icon .. " " .. self.count)
            end,
            hl = { fg = "diag_" .. type },
          },
          spacer,
        },
      }
    end

    local Diagnostics = {
      condition = conditions.has_diagnostics,
      init = function(self)
        self.c = vim.diagnostic.count(0)
      end,
      {
        Diagnostic("error"),
        Diagnostic("warn"),
        Diagnostic("info"),
        Diagnostic("hint", true),
        Pad,
      },
    }

    local function File(buf)
      return {
        init = function(self)
          self.buf = buf or 0
          self.filename = vim.api.nvim_buf_get_name(self.buf)
          self.filetype = vim.bo[self.buf].filetype
        end,
      }
    end

    local FileDir = {
      init = function(self)
        self.dir = vim.fn.fnamemodify(self.filename, ":.:h")
        if self.dir == "" then self.dir = "[No Name]" end
      end,
      flexible = priorities.FileDir,
      hl = { fg = "dimmed_fg" },
      {
        {
          provider = function(self)
            local trail = self.dir:sub(-1) == "/" and "" or "/"
            return self.dir .. trail
          end,
        },
        Space,
      },
      {
        {
          provider = function(self)
            local short_dir = vim.fn.pathshorten(self.dir)
            local trail = short_dir:sub(-1) == "/" and "" or "/"
            return short_dir .. trail
          end,
        },
        Space,
      },
      { provider = "" },
    }

    local FileIcon = {
      init = function(self)
        local get_icon = require("mini.icons").get
        local is_default = false
        self.icon, self.hl, is_default = get_icon("file", self.filename)
        if is_default then self.icon, self.hl, _ = get_icon("filetype", self.filetype) end
      end,
      hl = function(self)
        return { fg = self.hl }
      end,
      {
        provider = function(self)
          return self.icon
        end,
      },
      Space,
    }

    local FileName = {
      provider = function(self)
        local filename = vim.fn.fnamemodify(self.filename, ":t")
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
          Space,
          {
            provider = "[+]",
            hl = { fg = "flag_fg" },
          },
        },
      },
      {
        condition = function()
          return not vim.bo.modifiable or vim.bo.readonly
        end,
        {
          Space,
          {
            provider = "",
            hl = { fg = "dimmed_fg" },
          },
        },
      },
    }

    local LspActive = {
      condition = conditions.lsp_attached,
      Pad,
      {
        provider = function()
          local names = {}
          for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
          end
          return " " .. table.concat(names, ", ")
        end,
      },
    }

    local Nav = {}

    local NavPosition = { provider = "%10(%l/%L:%c%)" }

    local NavPercentage = {
      { provider = "%P" },
      Space,
      {
        static = {
          sbar = { "🭶", "🭷", "🭸", "🭹", "🭺", "🭻" }
        },
        provider = function(self)
          local curr_line = vim.api.nvim_win_get_cursor(0)[1]
          local lines = vim.api.nvim_buf_line_count(0)
          local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
          return string.rep(self.sbar[i], 2)
        end,
        hl = { fg = "bright_fg", bg = "bright_bg" },
      },
    }

    local function BreadcrumbsItem(symbol)
      local spacer
      local icon = symbol.icon or ""
      local name = symbol.name or ""
      if icon == "" then spacer = nil else spacer = Space end
      local kind
      if type(symbol.kind) == "string" then
        kind = symbol.kind
      elseif type(symbol.kind) == "number" then
        kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown"
      end
      if name ~= "" then
        return {
          Space,
          {
            provider = icon,
            hl = { fg = utils.get_highlight("Aerial" .. kind .. "Icon").fg },
          },
          spacer,
          {
            provider = name,
            hl = { fg = utils.get_highlight("Aerial" .. kind).fg },
          },
          Space,
        }
      end
    end

    local BreadcrumbsSep = { provider = "" }

    local Breadcrumbs = {
      condition = function()
        local ok, aerial = pcall(require, "aerial")
        if not ok then return false end
        local loc = aerial.get_location(true)
        return loc and not vim.tbl_isempty(loc)
      end,
      init = function(self)
        local symbols = require("aerial").get_location(true) or {}
        local children = {}
        for i, symbol in ipairs(symbols) do
          if i ~= 1 then table.insert(children, BreadcrumbsSep) end
          table.insert(children, BreadcrumbsItem(symbol))
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
      init = function(self)
        self.child = self:new(utils.insert(File(self.bufnr),
          FileBufnr,
          FileIcon,
          FileName,
          FileFlags
        ), 1)
      end,
      provider = function(self)
        return self.child:eval()
      end,
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
      hl = {}
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
      Space,
      {
        hl = function(self)
          if self.is_active then
            return { fg = "buffer_active_fg", bg = "buffer_active_bg" }
          else
            return { fg = "buffer_inactive_fg", bg = "buffer_inactive_bg", force = true }
          end
        end,
        Space,
        BufferFile,
        BufferCloseButton,
        Space,
      },
    }

    local Nvim = {
      hl = function(self)
        return { fg = "black", bg = self.color }
      end,
      provider = "",
    }

    local Tab = {
      provider = function(self)
        return "%" .. self.tabnr .. "T " .. self.tabpage .. " %T"
      end,
      hl = function(self)
        if self.is_active then
          return { fg = "tab_active_fg", bg = "tab_active_bg" }
        else
          return { fg = "tab_inactive_fg", bg = "tab_inactive_bg", force = true }
        end
      end,
    }

    local TabCloseButton = {
      provider = "%999X  %X",
      hl = { fg = "close" },
    }

    local SignColumn = {
      Space,
      { provider = "%s" },
    }

    local NumberColumn = {
      condition = function() return vim.opt_local.number end,
      { provider = "%l" },
      Space,
    }

    local FoldColumn = {
      condition = function() return vim.opt_local.foldenable and vim.v.virtnum == 0 end,
      { provider = "%C" },
      Space,
    }


    local ModeLeft = utils.insert(Mode,
      ModeBar,
      ModeText,
      Pad
    )

    Git = utils.insert(Git,
      GitBranch,
      GitDiffs,
      Pad
    )

    local StatuslineFile = utils.insert(File(0),
      FileDir,
      FileIcon,
      FileName,
      FileFlags,
      Pad
    )

    Nav = utils.insert(Nav,
      Pad,
      NavPosition,
      Pad,
      NavPercentage
    )

    local ModeRight = utils.insert(Mode,
      Pad,
      ModeBar
    )

    local ModeNvim = utils.insert(Mode,
      ModeBar,
      Nvim,
      ModeBar
    )

    local Buffers = {
      utils.make_buflist(Buffer),
    }

    local Tabs = {
      condition = function()
        return #vim.api.nvim_list_tabpages() >= 2
      end,
      utils.make_tablist(Tab),
      TabCloseButton,
    }

    local ActiveStatusline = { ModeLeft, Git, Diagnostics, StatuslineFile, Align, LspActive, Nav, ModeRight }

    local InactiveStatusline = {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      { ModeBar, Pad, StatuslineFile, Align, Nav, Pad, ModeBar },
    }

    local ActiveWinbar = {
      hl = { bg = "winbar_bg" },
      Breadcrumbs,
      Align,
    }

    local InactiveWinbar = {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      Breadcrumbs,
      Align,
    }

    local Tabline = { ModeNvim, Buffers, Align, Pad, Tabs }

    local function component(active, inactive)
      return {
        fallthrough = false,
        {
          condition = conditions.is_active,
          active,
        },
        inactive,
      }
    end

    local function from_disk(buf)
      local buf_name = vim.api.nvim_buf_get_name(buf)
      return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and buf_name ~= "" and
          buf_name ~= nil
    end

    local StatusColumn = {
      condition = function() return from_disk(vim.api.nvim_get_current_buf()) end,
      SignColumn,
      NumberColumn,
      FoldColumn,
    }

    require("heirline").setup({
      opts = {
        disable_winbar_cb = function(ev) return not from_disk(ev.buf) end,
        colors = get_colors,
      },
      statusline = component(ActiveStatusline, InactiveStatusline),
      winbar = component(ActiveWinbar, InactiveWinbar),
      tabline = Tabline,
      statuscolumn = StatusColumn,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
        vim.cmd("redrawtabline")
      end)
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        utils.on_colorscheme(get_colors)
      end,
    })
  end,
}
