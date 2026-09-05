--- Configuration for the `mini.starter` plugin.
local sessions = require('sessions')

vim.pack.add({ 'https://github.com/nvim-mini/mini.starter' })

local fzf = require('fzf-lua')
local starter = require('mini.starter')

--- Generates a greeting based on the time of day.
---
--- The time of day is defined as:
---
--- * Morning from 00:00 to 11:59
--- * Afternoon from 12:00 to 17:59
--- * Evening from 18:00 to 23:59
local function greeting()
  local hour = tonumber(vim.fn.strftime('%H'))
  local part_id = math.floor(hour / 6) + 1
  local day_part = ({ 'morning', 'morning', 'afternoon', 'evening' })[part_id]
  local username = vim.uv.os_get_passwd()['username'] or 'USERNAME'

  return ('Good %s, %s'):format(day_part, username)
end

--- Generates a list of recent sessions that load on selection.
---
--- @param max? integer Number of recent sessions to show.
local function recent_sessions_items(max)
  max = max or 3

  local names = sessions.names()
  local items = {}

  for i = 1, math.min(max, #names) do
    local name = names[i]

    table.insert(items, {
      name = name,
      section = 'Recent sessions',
      action = function()
        pcall(starter.close)
        sessions.load(name)
      end,
    })
  end

  return items
end

--- Generates a list of picker functions that execute on selection.
local function pick_items()
  local function item(name, action)
    return { name = name, section = 'Pick', action = action }
  end

  return {
    item('file', fzf.files),
    item('recent file', fzf.oldfiles),
    item('live grep', fzf.live_grep),
    item('session', sessions.load_select),
    item('directory', fzf.dirs),
  }
end

starter.setup({
  -- Select when query defines a single item.
  evaluate_single = true,
  header = greeting,
  items = {
    recent_sessions_items,
    pick_items,
  },
  footer = '',
  content_hooks = {
    -- Add block-character bullets to each item.
    starter.gen_hook.adding_bullet(),
    -- Centre content in the window.
    starter.gen_hook.aligning('center', 'center'),
  },
  silent = true,
})

-- Refreshes all `mini.starter` buffers.
local refresh = vim.schedule_wrap(function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local filetype = vim.api.nvim_get_option_value('filetype', { buf = buf })

    if filetype == 'ministarter' then
      pcall(starter.refresh, buf)
    end
  end
end)

local ministarter_refresh_group =
  vim.api.nvim_create_augroup('MinistarterRefresh', { clear = true })

-- Refresh on focusing `mini.starter` buffers, and on session writing.
vim.api.nvim_create_autocmd({ 'FocusGained', 'SessionWritePost' }, {
  callback = refresh,
  group = ministarter_refresh_group,
})

-- Refresh on user-defined events that signal session changes.
vim.api.nvim_create_autocmd('User', {
  pattern = {
    'SessionDeletePost',
    'SessionRenamePost',
  },
  callback = refresh,
  group = ministarter_refresh_group,
})
