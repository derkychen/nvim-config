return {
  "nvim-mini/mini.starter",
  version = "*",
  config = function()
    local starter = require("mini.starter")
    local sessions = require("sessions")

    local function session_items(max)
      max = max or 5
      local names = sessions.names()
      local items = {}
      for i = 1, math.min(max, #names) do
        local name = names[i]
        table.insert(items, {
          name = name,
          section = "Sessions",
          action = function()
            pcall(starter.close)
            sessions.load(sessions.get_session_path(name))
          end,
        })
      end
      return items
    end

    local function fzf_items()
      return {
        { action = "FzfLua files",       name = "file",             section = "Find" },
        { action = "FzfLua oldfiles",    name = "recent files",     section = "Find" },
        { action = "FzfLua live_grep",   name = "live grep",        section = "Find" },
        { action = "TcdThenCwdExplorer", name = "change directory", section = "Find" },
      }
    end

    starter.setup({
      items = {
        session_items(),
        fzf_items(),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning("center", "center"),
      }
    })
    vim.api.nvim_create_autocmd("TabNew", {
      callback = function()
        vim.schedule(function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          local modified = vim.bo[buf].modified
          local line_count = vim.api.nvim_buf_line_count(buf)

          if name == "" and bt == "" and not modified and line_count <= 1 then
            starter.open()
          end
        end)
      end,
    })
    vim.api.nvim_create_autocmd({ "VimEnter", "VimResized", "WinResized" }, {
      callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype == "ministarter" then
            starter.refresh()
          end
        end
      end
    })
  end,
}
