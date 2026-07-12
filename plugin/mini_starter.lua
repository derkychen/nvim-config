vim.pack.add({ "https://github.com/nvim-mini/mini.starter" })

local starter = require("mini.starter")
local sessions = require("sessions")
local fzf_lua = require("fzf-lua")

local function greeting()
  local hour = tonumber(vim.fn.strftime("%H"))
  local part_id = math.floor((hour) / 6) + 1
  local day_part = ({ "morning", "morning", "afternoon", "evening" })[part_id]
  local username = vim.uv.os_get_passwd()["username"] or "USERNAME"

  return ("Good %s, %s"):format(day_part, username)
end

local function session_items(max)
  max = max or 3
  local names = sessions.names()
  local items = {}
  for i = 1, math.min(max, #names) do
    local name = names[i]
    table.insert(items, {
      name = name,
      section = "Recent sessions",
      action = function()
        pcall(starter.close)
        sessions.load(name)
      end,
    })
  end
  return items
end

local function fzf_lua_items()
  local function item(name, action)
    return { name = name, section = "Find", action = action }
  end
  return {
    item("file", fzf_lua.files),
    item("recent file", fzf_lua.oldfiles),
    item("live grep", fzf_lua.live_grep),
    item("session", sessions.load_select),
    item("change directory", fzf_lua.cd),
  }
end

starter.setup({
  evaluate_single = true,
  header = greeting,
  items = {
    session_items,
    fzf_lua_items,
  },
  footer = "",
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning("center", "center"),
  },
  silent = true,
})

local refresh = vim.schedule_wrap(function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if filetype == "ministarter" then
      pcall(starter.refresh, buf)
    end
  end
end)

local ministarter_refresh_group = vim.api.nvim_create_augroup(
  "MinistarterRefresh", { clear = true })

-- Update time of day
vim.api.nvim_create_autocmd("FocusGained", {
  callback = refresh,
  group = ministarter_refresh_group,
})

-- Update sessions
vim.api.nvim_create_autocmd("SessionWritePost", {
  callback = refresh,
  group = ministarter_refresh_group,
})

vim.api.nvim_create_autocmd("User", {
  pattern = {
    "SessionDeletePost",
    "SessionRenamePost",
  },
  callback = refresh,
  group = ministarter_refresh_group,
})
