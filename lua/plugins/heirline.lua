local utils = require("utils")

return {
  "rebelot/heirline.nvim",
  config = function()
    local hconds = require("heirline.conditions")
    local hutils = require("heirline.utils")

    -- Flexible component priorities
    local priorities = {
      FileDir = 1,
      GitBranch = 5,
      ModeText = 2,
      LspActive = 6,
      NavPosition = 4,
      NavPercentage = 3,
    }

    -- Common components
    local Space = setmetatable({ provider = " " }, {
      __call = function(_, num)
        return { provider = string.rep(" ", num or 1) }
      end,
    })
    local Pad = { provider = "    ", hl = { bg = "none" } }
    local HalfPad = { provider = "  ", hl = { bg = "none" } }
    local Trunc = { provider = "%<" }
    local Align = { provider = "%=" }
    local Bar = { provider = "█" }

    local function add_padding(component)
      return {
        condition = component.condition,
        HalfPad,
        component,
        HalfPad,
      }
    end

    local function component(active, inactive)
      return {
        fallthrough = false,
        {
          condition = hconds.is_active,
          active,
        },
        inactive,
      }
    end

    -- Colors
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
      condition = hconds.has_diagnostics,
      init = function(self)
        self.c = vim.diagnostic.count(0)
      end,
      add_padding({
        Diagnostic("error"),
        Diagnostic("warn"),
        Diagnostic("info"),
        Diagnostic("hint", true),
      }),
    }

    local function File(buf)
      return {
        init = function(self)
          self.buf = buf or 0
          self.filename = vim.api.nvim_buf_get_name(buf)
          self.filetype = vim.bo[self.buf].filetype
        end,
      }
    end

    local FileDir = {
      init = function(self)
        local filepath = utils.winrelpath(self.winnr)
        self.dir = vim.fn.fnamemodify(filepath, ":h")
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
      Space,
    }

    local FileName = {
      provider = function(self)
        local filename = vim.fn.fnamemodify(self.filename, ":t")
        if utils.valid_normal_buf(self.buf) then
          filename = vim.fs.basename(self.filename)
        end
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
      condition = hconds.lsp_attached,
      {
        flexible = priorities.LspActive,
        add_padding({
          provider = function()
            local names = {}
            for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
              table.insert(names, server.name)
            end
            return " " .. table.concat(names, ", ")
          end,
        }),
        add_padding({ provider = "" }),
        { provider = "" },
      },
    }

    local Nav = {}

    local NavPosition = {
      flexible = priorities.NavPosition,
      add_padding({ provider = "%10(%l/%L:%c%)" }),
      add_padding({ provider = "%6(%l:%c%)" }),
      { provider = "" },
    }

    local NavPercentage = {
      flexible = priorities.NavPercentage,
      add_padding({
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
      }),
      add_padding({ provider = "%P" }),
      { provider = "" },
    }

    local BreadcrumbsSep = { provider = "" }

    -- figure out window vs buffer stuff
    local function BreadcrumbsPathItem(name, is_file)
      local get_icon = require("mini.icons").get
      is_file = is_file or false
      local spacer
      local icon, hl
      icon, hl, _ = get_icon("directory", name)
      if is_file then
        icon, hl = get_icon("file", name)
      end
      if icon == "" then spacer = nil else spacer = Space end
      if name ~= "" then
        return {
          Space,
          {
            provider = icon,
            hl = { fg = hutils.get_highlight(hl).fg },
          },
          spacer,
          {
            provider = name,
          },
          Space,
        }
      end
    end

    local BreadcrumbsPath = {
      init = function(self)
        local names = {}
        for name in string.gmatch(utils.winrelpath(self.winnr), "([^/]+)") do
          table.insert(names, name)
        end
        local children = {}
        for i, name in ipairs(names) do
          if i ~= 1 then table.insert(children, BreadcrumbsSep) end
          if i ~= #names then
            table.insert(children, BreadcrumbsPathItem(name))
          else
            table.insert(children, BreadcrumbsPathItem(name, true))
          end
        end
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
            hl = { fg = hutils.get_highlight("Aerial" .. kind .. "Icon").fg },
          },
          spacer,
          {
            provider = name,
            hl = { fg = hutils.get_highlight("Aerial" .. kind).fg },
          },
          Space,
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
      init = function(self)
        self.child = self:new(hutils.insert(File(self.bufnr),
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

    local SignColumn = { provider = "%s" }

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


    local ModeIndicator = hutils.insert(Mode,
      ModeBar,
      ModeText
    )

    Git = add_padding(hutils.insert(Git,
      GitBranch,
      GitDiffs
    ))

    local StatuslineFile = add_padding(hutils.insert(File(0),
      FileDir,
      FileIcon,
      FileName,
      FileFlags
    ))

    Nav = hutils.insert(Nav,
      NavPosition,
      NavPercentage
    )

    local ModeRight = hutils.insert(Mode,
      ModeBar
    )

    local Breadcrumbs = { BreadcrumbsPath, BreadcrumbsAerial }

    local ModeNvim = hutils.insert(Mode,
      ModeBar,
      Nvim,
      ModeBar
    )

    local Buffers = {
      hutils.make_buflist(Buffer),
    }

    local Tabs = {
      condition = function()
        return #vim.api.nvim_list_tabpages() >= 2
      end,
      hutils.make_tablist(Tab),
      TabCloseButton,
    }

    local ActiveStatusline = {
      ModeIndicator,
      HalfPad,
      Git,
      Diagnostics,
      Trunc,
      StatuslineFile,
      Align,
      LspActive,
      Nav,
      HalfPad,
      ModeRight,
    }

    local InactiveStatusline = {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      Bar,
      HalfPad,
      Trunc,
      StatuslineFile,
      Align,
      Nav,
      Bar,
      HalfPad,
      Bar,
    }

    local ActiveWinbar = {
      Breadcrumbs,
      Align,
    }

    local InactiveWinbar = {
      hl = { fg = "inactive_fg", bg = "inactive_bg", force = true },
      Breadcrumbs,
      Align,
    }

    local Tabline = {
      callback = function()
        return #vim.api.nvim_list_bufs() > 1 or #vim.api.nvim_list_tabpages() > 1
      end,
      ModeNvim,
      Trunc,
      Buffers,
      Align,
      Pad,
      Tabs,
    }

    local StatusColumn = {
      condition = function(self)
        return utils.valid_normal_buf_winnr(self.winnr)
      end,
      Space,
      SignColumn,
      NumberColumn,
      FoldColumn,
    }

    require("heirline").setup({
      opts = {
        disable_winbar_cb = function(ev)
          return not utils.valid_normal_buf(ev.buf)
        end,
        colors = get_colors,
      },
      statusline = component(ActiveStatusline, InactiveStatusline),
      winbar = component(ActiveWinbar, InactiveWinbar),
      tabline = Tabline,
      statuscolumn = StatusColumn,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
      callback = vim.schedule_wrap(function()
        vim.cmd.redrawstatus()
        vim.cmd.redrawtabline()
      end)
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        hutils.on_colorscheme(get_colors)
      end,
    })

    vim.api.nvim_create_autocmd({
      "BufAdd",
      "BufDelete",
      "BufEnter",
      "BufWinEnter",
      "TabNew",
      "TabClosed",
      "VimEnter",
    }, {
      callback = vim.schedule_wrap(function()
        local num_listed_bufs = #vim.fn.getbufinfo({ buflisted = 1 })
        local num_tabs = #vim.api.nvim_list_tabpages()

        vim.opt.showtabline = (num_listed_bufs > 1 or num_tabs > 1) and 2 or 0
      end)
    })
  end,
}
