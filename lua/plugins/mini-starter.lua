return {
  "nvim-mini/mini.starter",
  version = "*",
  config = function()
    local starter = require("mini.starter")
    local sessions = require("sessions")

    local greeting = function()
      local hour = tonumber(vim.fn.strftime("%H"))
      local part_id = math.floor((hour) / 6) + 1
      local day_part = ({ "morning", "morning", "afternoon", "evening" })[part_id]
      local username = vim.loop.os_get_passwd()["username"] or "USERNAME"

      return ("Good %s, %s"):format(day_part, username)
    end

    local session_items = function(max)
      max = max or 5
      local names = sessions.names()
      local items = {}
      for i = 1, math.min(max, #names) do
        local name = names[i]
        table.insert(items, {
          name = name,
          section = "Recent sessions",
          action = function()
            pcall(starter.close)
            sessions.load(sessions.get_session_path(name))
          end,
        })
      end
      return items
    end

    local fzf_items = function()
      return {
        { name = "file",             section = "Fuzzy find", action = "FzfLua files", },
        { name = "recent files",     section = "Fuzzy find", action = "FzfLua oldfiles", },
        { name = "live grep",        section = "Fuzzy find", action = "FzfLua live_grep", },
        { name = "sessions",         section = "Fuzzy find", action = "SessionLoadByName" },
        { name = "change directory", section = "Fuzzy find", action = "TcdThenCwdExplorer", },
      }
    end

    starter.setup({
      evaluate_single = true,
      header = greeting,
      items = {
        session_items,
        fzf_items,
      },
      footer = "",
      content_hooks = {
        starter.gen_hook.adding_bullet(),
        starter.gen_hook.aligning("center", "center"),
      }
    })

    vim.api.nvim_create_autocmd({ "WinResized", "FocusGained" }, {
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "ministarter" then
            starter.refresh(buf)
          end
        end
      end
    })
  end,
}
