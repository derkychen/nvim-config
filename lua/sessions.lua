local M = {}

-- Session storage directory
M.sessions_dir = vim.fn.stdpath("data") .. "/sessions"

-- Ensure session storage directory exists
if vim.fn.isdirectory(M.sessions_dir) == 0 then
  vim.fn.mkdir(M.sessions_dir, "p")
end

local function msg(...)
  vim.notify(...)
end

-- File path from session name
function M.get_session_path(session_name)
  return M.sessions_dir .. "/" .. session_name .. ".vim"
end

-- Save session
function M.save(path)
  vim.cmd("mksession! " .. vim.fn.fnameescape(path))
  msg("Session saved: " .. path)
end

-- Load session
function M.load(path)
  if vim.fn.filereadable(path) == 0 then
    msg("No such session: " .. path)
    return
  end
  vim.cmd("silent! source " .. vim.fn.fnameescape(path))
  msg("Session loaded: " .. path)
end

-- Delete session
function M.delete(path)
  if vim.fn.filereadable(path) == 0 then
    msg("No such session: " .. path)
    return
  end

  vim.fn.delete(path)
  msg("Session deleted: " .. path)
end

-- Save current session
function M.save_current()
  M.save(M.get_session_path(vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
end

-- Delete current session
function M.delete_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    msg("No current session loaded")
    return
  end
  M.delete(vim.v.this_session)
  vim.v.this_session = ""
end

vim.api.nvim_create_user_command("SessionSaveCurrent", M.save_current, {})
vim.api.nvim_create_user_command("SessionDeleteCurrent", M.save_current, {})

-- Return all session names
function M.names()
  local paths = vim.fn.globpath(M.sessions_dir, "*.vim", false, true)
  local paths_and_times = {}
  for _, path in ipairs(paths) do
    local stat = vim.loop.fs_stat(path)
    local mtime = stat and stat.mtime and stat.mtime.sec or 0
    table.insert(paths_and_times, { path = path, mtime = mtime })
  end

  table.sort(paths_and_times, function(a, b)
    return a.mtime > b.mtime
  end)

  local names = {}
  for _, entry in ipairs(paths_and_times) do
    table.insert(names, vim.fn.fnamemodify(entry.path, ":t:r"))
  end
  return names
end

function M.save_to_name()
  local items = vim.deepcopy(M.names())
  table.insert(items, 1, " Create new session")

  vim.ui.select(items, { prompt = "Save or create new session: " }, function(choice, idx)
    if not choice then return end

    if idx == 1 then
      vim.ui.input({
        prompt = "Session name: ",
        default = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
      }, function(name)
        if not name or name == "" then
          return
        end
        vim.defer_fn(function()
          M.save(M.get_session_path(name))
        end, 50)
      end)
    end
  end)
end

function M.load_from_name()
  vim.ui.select(M.names(), { prompt = "Load session: " }, function(choice)
    if not choice or choice == "" then return end
    vim.defer_fn(function()
      M.load(M.get_session_path(choice))
    end, 50)
  end)
end

function M.delete_by_name()
  vim.ui.select(M.names(), { prompt = "Delete session: " }, function(choice)
    if not choice or choice == "" then return end
    vim.defer_fn(function()
      M.delete(M.get_session_path(choice))
    end, 50)
  end)
end

return M
