local M = {}

-- Sessions data
M.dir = vim.fs.joinpath(vim.fn.stdpath("data"), "sessions")
M.lastused_path = vim.fs.joinpath(M.dir, ".lastused")

-- Read last-used file into a table
local function read_lastused()
  local lastused = {}

  local f = io.open(M.lastused_path, "r")
  if not f then
    return lastused
  end

  for line in f:lines() do
    local name, ts = line:match("^(.-)\t(%d+)$")
    if name and ts then
      lastused[name] = tonumber(ts)
    end
  end

  f:close()
  return lastused
end

-- Write a table to last-used file
local function write_lastused(lastused)
  local f = io.open(M.lastused_path, "w")
  if not f then
    vim.notify("Failed to write session last-used file.", vim.log.levels.WARN)
    return
  end

  local names = vim.tbl_keys(lastused)
  table.sort(names)

  for _, name in ipairs(names) do
    f:write(name .. "\t" .. tostring(lastused[name]) .. "\n")
  end

  f:close()
end

-- Mark a last-used session with new timestamp
local function mark_lastused(name)
  local lastused = read_lastused()

  lastused[name] = os.time()
  write_lastused(lastused)
end

-- Delete a last-used session
local function delete_lastused(name)
  local lastused = read_lastused()

  lastused[name] = nil
  write_lastused(lastused)
end

-- Rename a last-used session
local function rename_lastused(old_name, new_name)
  local lastused = read_lastused()
  local old_time = lastused[old_name]

  lastused[old_name] = nil
  lastused[new_name] = old_time

  write_lastused(lastused)
end

-- Session file path from session name
function M.get_path(name)
  return vim.fs.joinpath(M.dir, name .. ".vim")
end

-- Session name from session file path
function M.get_name(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

-- Save session
function M.save(path)
  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionSavePre",
    modeline = false,
    data = { path = path },
  })

  vim.cmd.mksession({
    bang = true,
    args = { path },
  })

  mark_lastused(M.get_name(path))

  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionSavePost",
    modeline = false,
    data = { path = path },
  })

  vim.notify("Session saved: " .. vim.fs.basename(path))
end

-- Load session
function M.load(path)
  if not vim.uv.fs_stat(path) then
    vim.notify("No such session: " .. vim.fs.basename(path))
    return
  end

  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionLoadPre",
    modeline = false,
    data = { path = path },
  })

  vim.api.nvim_cmd({
    cmd = "source",
    args = { path },
    mods = {
      silent = true,
      emsg_silent = true,
    },
  }, {})

  mark_lastused(M.get_name(path))

  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionLoadPost",
    modeline = false,
    data = { path = path },
  })

  vim.notify("Session loaded: " .. vim.fs.basename(path))
end

-- Delete session
function M.delete(path)
  if not vim.uv.fs_stat(path) then
    vim.notify("No such session: " .. vim.fs.basename(path))
    return
  end

  vim.fs.rm(path)
  delete_lastused(M.get_name(path))

  vim.notify("Session deleted: " .. vim.fs.basename(path))
end

-- Rename session
function M.rename(old_path, new_path, overwrite)
  if not vim.uv.fs_stat(old_path) then
    vim.notify("No such session: " .. vim.fs.basename(old_path))
    return
  end

  if vim.uv.fs_stat(new_path) then
    if not overwrite then
      vim.notify("Session already exists: " .. vim.fs.basename(new_path))
      return
    end

    vim.fs.rm(new_path)
    delete_lastused(M.get_name(new_path))
  end

  local old_name = M.get_name(old_path)
  local new_name = M.get_name(new_path)

  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionRenamePre",
    modeline = false,
    data = {
      old_name = old_name,
      new_name = new_name,
    },
  })

  local ok = vim.fn.rename(old_path, new_path)
  if ok ~= 0 then
    vim.notify("Failed to rename session: " ..
      vim.fs.basename(old_path) ..
      " -> " .. vim.fs.basename(new_path))
    return
  end

  vim.api.nvim_exec_autocmds("User", {
    pattern = "SessionRenamePost",
    modeline = false,
    data = {
      old_name = old_name,
      new_name = new_name,
    },
  })

  rename_lastused(old_name, new_name)

  vim.notify("Session renamed: " ..
    vim.fs.basename(old_path) ..
    " -> " .. vim.fs.basename(new_path))
end

-- Return all session names ordered from most to least recent use
function M.names()
  local paths = vim.fn.globpath(M.dir, "*.vim", false, true,
    true)
  local lastused = read_lastused()

  local entries = {}

  for _, path in ipairs(paths) do
    local name = M.get_name(path)
    local stat = vim.uv.fs_stat(path)

    table.insert(entries, {
      name = name,
      path = path,
      lastused_ts = lastused[name] or 0,
      mtime = stat and stat.mtime and stat.mtime.sec or 0,
    })
  end

  table.sort(entries, function(a, b)
    if a.lastused_ts ~= b.lastused_ts then
      return a.lastused_ts > b.lastused_ts
    end

    if a.mtime ~= b.mtime then
      return a.mtime > b.mtime
    end

    return a.name < b.name
  end)

  local names = {}
  for _, entry in ipairs(entries) do
    table.insert(names, entry.name)
  end

  return names
end

-- Save current session
function M.save_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    M.save(M.get_path(vim.fs.basename(vim.fn.getcwd())))
    return
  end
  M.save(vim.v.this_session)
end

function M.save_select()
  local items = vim.deepcopy(M.names())
  table.insert(items, 1, " Create new session")

  vim.ui.select(
    items,
    { prompt = "Save or create new session > " },
    function(choice, idx)
      if not choice then
        vim.notify("Session save canceled.")
        return
      end

      if idx == 1 then
        vim.ui.input({
          prompt = "Session name: ",
          default = vim.fs.basename(vim.fn.getcwd()),
        }, function(name)
          if not name or name == "" then
            vim.notify("Session save canceled.")
            return
          end
          M.save(M.get_path(name))
        end)
      else
        M.save(M.get_path(choice))
      end
    end
  )
end

-- Session loading
function M.load_select()
  vim.ui.select(M.names(), { prompt = "Load session > " }, function(choice)
    if not choice or choice == "" then
      vim.notify("Session load canceled.")
      return
    end
    M.load(M.get_path(choice))
  end)
end

-- Session deletion
function M.delete_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    vim.notify("No current session loaded.")
    return
  end
  M.delete(vim.v.this_session)
  vim.v.this_session = ""
end

function M.delete_select()
  vim.ui.select(M.names(), { prompt = "Delete session > " }, function(choice)
    if not choice or choice == "" then
      vim.notify("Session delete canceled.")
      return
    end
    M.delete(M.get_path(choice))
  end)
end

-- Session renaming
function M.rename_current()
  local current = vim.v.this_session
  if current == nil or current == "" then
    vim.notify("No current session.")
    return
  end

  local old_path = current
  local old_name = M.get_name(old_path)

  vim.ui.input({
    prompt = "Rename current session to: ",
    default = old_name,
  }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then
      vim.notify("Session rename canceled.")
      return
    end

    local new_path = M.get_path(new_name)

    local function do_rename(overwrite)
      M.rename(old_path, new_path, overwrite)
      if vim.uv.fs_stat(new_path) then
        vim.v.this_session = new_path
      end
    end

    if vim.uv.fs_stat(new_path) then
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

function M.rename_select()
  vim.ui.select(M.names(), { prompt = "Rename session > " }, function(choice)
    if not choice or choice == "" then
      return
    end

    vim.ui.input({
      prompt = "Rename '" .. choice .. "' to: ",
      default = choice,
    }, function(new_name)
      if not new_name or new_name == "" or new_name == choice then
        vim.notify("Session rename canceled.")
        return
      end

      local old_path = M.get_path(choice)
      local new_path = M.get_path(new_name)

      local function do_rename(overwrite)
        M.rename(old_path, new_path, overwrite)
        if vim.v.this_session == old_path and vim.uv.fs_stat(new_path) then
          vim.v.this_session = new_path
        end
      end

      if vim.uv.fs_stat(new_path) then
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

function M.setup()
  -- Ensure session storage directory exists
  if vim.fn.isdirectory(M.dir) == 0 then
    vim.fn.mkdir(M.dir, "p")
  end

  -- Ensure last-used file exists
  if vim.fn.filereadable(M.lastused_path) == 0 then
    local f = io.open(M.lastused_path, "w")
    if f then
      f:close()
    else
      vim.notify("Failed to create session last-used file.", vim.log.levels.WARN)
    end
  end

  vim.keymap.set("n", "<Leader>ss", M.save_current,
    { desc = "Save current session" })
  vim.keymap.set("n", "<Leader>sa", M.save_select,
    { desc = "Select a name to save current session to" })
  vim.keymap.set("n", "<Leader>sl", M.load_select,
    { desc = "Select session to load" })
  vim.keymap.set("n", "<Leader>sx", M.delete_current,
    { desc = "Delete current session" })
  vim.keymap.set("n", "<Leader>sd", M.delete_select,
    { desc = "Select session to delete" })
  vim.keymap.set("n", "<Leader>sr", M.rename_current,
    { desc = "Rename current session" })
  vim.keymap.set("n", "<Leader>sc", M.rename_select,
    { desc = "Select session to rename" })
end

return M
