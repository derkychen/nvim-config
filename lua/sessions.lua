local M = {}

-- Session storage directory
M.sessions_dir = vim.fn.stdpath("data") .. "/sessions"

-- Ensure session storage directory exists
if vim.fn.isdirectory(M.sessions_dir) == 0 then
  vim.fn.mkdir(M.sessions_dir, "p")
end

-- User messaging interface, delay to accommodate for vim.ui.select picker
local function msg(s)
  vim.defer_fn(function()
    vim.notify(s)
  end, 50)
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

-- Rename session
function M.rename(old_path, new_path, overwrite)
  if vim.fn.filereadable(old_path) == 0 then
    msg("No such session: " .. old_path)
    return
  end

  if vim.fn.filereadable(new_path) == 1 then
    if not overwrite then
      msg("Session already exists: " .. new_path)
      return
    end
    vim.fn.delete(new_path)
  end

  local ok = vim.fn.rename(old_path, new_path)
  if ok ~= 0 then
    msg("Failed to rename session: " .. old_path .. " -> " .. new_path)
    return
  end

  msg("Session renamed: " .. old_path .. " -> " .. new_path)
end

-- Return all session names
function M.names()
  local paths = vim.fn.globpath(M.sessions_dir, "*.vim", false, true, true)
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

-- Save current session
function M.save_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    M.save(M.get_session_path(vim.fn.fnamemodify(vim.fn.getcwd(), ":t")))
    return
  end
  M.save(vim.v.this_session)
end

function M.save_to_name()
  local items = vim.deepcopy(M.names())
  table.insert(items, 1, " Create new session")

  vim.ui.select(items, { prompt = "Save or create new session > " }, function(choice, idx)
    if not choice then
      msg("Session save canceled.")
      return
    end

    if idx == 1 then
      vim.ui.input({
        prompt = "Session name: ",
        default = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
      }, function(name)
        if not name or name == "" then
          msg("Session save canceled.")
          return
        end
        M.save(M.get_session_path(name))
      end)
    else
      M.save(M.get_session_path(choice))
    end
  end)
end

-- Session loading
function M.load_by_name()
  vim.ui.select(M.names(), { prompt = "Load session > " }, function(choice)
    if not choice or choice == "" then
      msg("Session load canceled.")
      return
    end
    M.load(M.get_session_path(choice))
  end)
end

-- Session deletion
function M.delete_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    msg("No current session loaded")
    return
  end
  M.delete(vim.v.this_session)
  vim.v.this_session = ""
end

function M.delete_by_name()
  vim.ui.select(M.names(), { prompt = "Delete session > " }, function(choice)
    if not choice or choice == "" then
      msg("Session delete canceled.")
      return
    end
    M.delete(M.get_session_path(choice))
  end)
end

-- Session renaming
function M.rename_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    msg("No current session")
    return
  end

  local old_path = current
  local old_name = vim.fn.fnamemodify(old_path, ":t:r")

  vim.ui.input({
    prompt = "Rename current session to: ",
    default = old_name,
  }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then
      msg("Session rename canceled.")
      return
    end

    local new_path = M.get_session_path(new_name)

    local function do_rename(overwrite)
      M.rename(old_path, new_path, overwrite)
      if vim.fn.filereadable(new_path) == 1 then
        vim.v.this_session = new_path
      end
    end

    if vim.fn.filereadable(new_path) == 1 then
      vim.ui.input({
        prompt = "Session exists. Overwrite? (y/N): ",
        default = "N",
      }, function(ans)
        if ans and ans:lower() == "y" then
          do_rename(true)
        end
      end)
    else
      do_rename(false)
    end
  end)
end

function M.rename_by_name()
  vim.ui.select(M.names(), { prompt = "Rename session > " }, function(choice)
    if not choice or choice == "" then return end

    vim.ui.input({
      prompt = "Rename '" .. choice .. "' to: ",
      default = choice,
    }, function(new_name)
      if not new_name or new_name == "" or new_name == choice then
        msg("Session rename canceled.")
        return
      end

      local old_path = M.get_session_path(choice)
      local new_path = M.get_session_path(new_name)

      local function do_rename(overwrite)
        M.rename(old_path, new_path, overwrite)
        if vim.v.this_session == old_path and vim.fn.filereadable(new_path) == 1 then
          vim.v.this_session = new_path
        end
      end

      if vim.fn.filereadable(new_path) == 1 then
        vim.ui.input({
          prompt = "Session exists. Overwrite? (y/N): ",
          default = "N",
        }, function(ans)
          if ans and ans:lower() == "y" then
            do_rename(true)
          end
        end)
      else
        do_rename(false)
      end
    end)
  end)
end

-- Commands
vim.api.nvim_create_user_command("SessionSaveCurrent", M.save_current, {})
vim.api.nvim_create_user_command("SessionSaveToName", M.save_to_name, {})
vim.api.nvim_create_user_command("SessionLoadByName", M.load_by_name, {})
vim.api.nvim_create_user_command("SessionDeleteCurrent", M.delete_current, {})
vim.api.nvim_create_user_command("SessionDeleteByName", M.delete_by_name, {})
vim.api.nvim_create_user_command("SessionRenameCurrent", M.rename_current, {})
vim.api.nvim_create_user_command("SessionRenameByName", M.rename_by_name, {})

-- Keymaps
vim.keymap.set("n", "<Leader>ss", M.save_current, {})
vim.keymap.set("n", "<Leader>sa", M.save_to_name, {})
vim.keymap.set("n", "<Leader>sl", M.load_by_name, {})
vim.keymap.set("n", "<Leader>sdc", M.delete_current, {})
vim.keymap.set("n", "<Leader>sdn", M.delete_by_name, {})
vim.keymap.set("n", "<Leader>src", M.rename_current, {})
vim.keymap.set("n", "<Leader>srn", M.rename_by_name, {})

return M
