--- Session management functionality.
---
--- This module only tracks sessions managed through it. It does not account for
--- the direct calling of `:mksession` and `:source`, etc.
local M = {}

-- Paths to where session data are stored.
local sessions_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'sessions')
local lastused_path = vim.fs.joinpath(sessions_dir, '.lastused')

--- Gets the file path of a session from its name.
---
--- @param name string Name of the session.
--- @return string path Full path of the corresponding session file.
local function get_path(name)
  return vim.fs.joinpath(sessions_dir, name .. '.vim')
end

--- Gets the name of a session from its file path.
---
--- @param path string Full path of the session file.
--- @return string name Name of the corresponding session.
local function get_name(path)
  local filename = vim.fs.basename(path)
  return filename:match('^(.*)%.[^.]+$') or filename
end

--- Gets the name of the current session.
---
--- @return string name Name of the current session.
local function current()
  return get_name(vim.v.this_session)
end

--- Checks the existence of session file from its name.
---
--- @param name string Name of the session whose existence is to be checked.
--- @return boolean exists Whether the session exists in the managed directory.
local function exists(name)
  return vim.uv.fs_stat(get_path(name)) ~= nil
end

--- Reads last-used file into a table.
---
--- @return string[] lastused List of names of last-used sessions.
local function read_lastused()
  local lastused = {}
  local f = io.open(lastused_path, 'r')

  if not f then
    return lastused
  end

  for line in f:lines() do
    local name = vim.trim(line)
    if name ~= '' then
      lastused[#lastused + 1] = name
    end
  end

  f:close()

  return lastused
end

--- Writes a table to last-used file.
---
--- @param lastused string[] List of names of last-used sessions.
local function write_lastused(lastused)
  local f = io.open(lastused_path, 'w')

  if not f then
    vim.notify('Failed to write session last-used file.', vim.log.levels.WARN)
    return
  end

  for _, name in ipairs(lastused) do
    f:write(name .. '\n')
  end

  f:close()
end

--- Marks a last-used session.
---
--- @param name string Name of the session to be marked as last-used.
local function mark_lastused(name)
  local lastused = { name }
  local old_lastused = read_lastused()

  for _, existing in ipairs(old_lastused) do
    if existing ~= name and exists(existing) then
      lastused[#lastused + 1] = existing
    end
  end

  write_lastused(lastused)
end

--- Deletes a last-used session.
---
--- @param name string Name of the session to delete from the last-used file.
local function delete_lastused(name)
  local old_lastused = read_lastused()
  local lastused = {}

  for _, existing in ipairs(old_lastused) do
    if existing ~= name and exists(existing) then
      lastused[#lastused + 1] = existing
    end
  end

  write_lastused(lastused)
end

--- Renames a last-used session.
---
--- @param old_name string Name of the session to rename.
--- @param new_name string New name of the session.
local function rename_lastused(old_name, new_name)
  local old_lastused = read_lastused()
  local lastused = {}
  local inserted = false

  for _, existing in ipairs(old_lastused) do
    if existing == old_name then
      if not inserted then
        lastused[#lastused + 1] = new_name
        inserted = true
      end
    elseif existing ~= new_name and exists(existing) then
      lastused[#lastused + 1] = existing
    end
  end

  if not inserted then
    table.insert(lastused, 1, new_name)
  end

  write_lastused(lastused)
end

--- Confirms if the user wants to overwrite an existing session.
---
--- @param name string Name of the session to overwrite.
--- @param callback fun(ans: boolean) Callback to execute on the response.
local function confirm_overwrite(name, callback)
  vim.ui.input({
    prompt = 'Session "' .. name .. '" already exists. Overwrite? (y/N): ',
    default = 'N',
  }, function(ans)
    callback(ans and ans:lower() == 'y')
  end)
end

--- Prompts the user to create a new session.
---
--- Prompts user to name the new session. Handles overwriting if the provided
--- name is of one that already exists.
local function new()
  local function do_save(name)
    M.save(name)
    vim.v.this_session = get_path(name)
  end

  vim.ui.input({
    prompt = 'Session name: ',
    default = vim.fs.basename(vim.uv.cwd()),
  }, function(name)
    if not name or name == '' then
      vim.notify('Session save canceled.')
      return
    end

    if exists(name) then
      confirm_overwrite(name, function(overwrite)
        if overwrite then
          do_save(name)
        else
          vim.notify('Session save canceled.')
        end
      end)
    else
      do_save(name)
    end
  end)
end

--- Saves a session.
---
--- This operation can be hooked with built-in `SessionWritePost` event.
---
--- TODO: Document the `SessionWritePre` event upon the release of 0.13.
---
--- @param name string Name of the session to save.
function M.save(name)
  local path = get_path(name)

  vim.cmd.mksession({
    path,
    bang = true,
  })

  mark_lastused(name)
  vim.notify('Session saved: ' .. name)
end

--- Loads a session.
---
--- This operation can be hooked with built-in `SessionLoadPre` and
--- `SessionLoadPost` events.
---
--- @param name string Name of the session to load.
function M.load(name)
  if not exists(name) then
    vim.notify('No such session: ' .. name)
    return
  end

  local path = get_path(name)

  vim.cmd.source({
    path,
    mods = {
      silent = true,
      emsg_silent = true,
    },
  })

  mark_lastused(name)
  vim.notify('Session loaded: ' .. name)
end

--- Deletes a session.
---
--- This operation can be hooked with the custom `SessionDeletePre` and
--- `SessionDeletePost` events.
---
--- @param name string Name of the session to delete.
function M.delete(name)
  if not exists(name) then
    vim.notify('No such session: ' .. name)
    return
  end

  local path = get_path(name)

  vim.api.nvim_exec_autocmds('User', {
    pattern = 'SessionDeletePre',
    modeline = false,
    data = { path = path },
  })

  vim.fs.rm(path)
  delete_lastused(name)

  vim.api.nvim_exec_autocmds('User', {
    pattern = 'SessionDeletePost',
    modeline = false,
    data = { path = path },
  })

  vim.notify('Session deleted: ' .. name)
end

--- Renames a session.
---
--- This operation can be hooked with the custom `SessionRenamePre` and
--- `SessionRenamePost` events. These events expose the old and new names pf the
--- session.
---
--- @param old_name string Name of the session to rename.
--- @param new_name string New name of the session.
function M.rename(old_name, new_name, overwrite)
  if not exists(old_name) then
    vim.notify('No such session: ' .. old_name)
    return
  end

  if exists(new_name) and not overwrite then
    vim.notify('Session already exists: ' .. new_name)
    return
  end

  vim.api.nvim_exec_autocmds('User', {
    pattern = 'SessionRenamePre',
    modeline = false,
    data = {
      old_name = old_name,
      new_name = new_name,
    },
  })

  local old_path = get_path(old_name)
  local new_path = get_path(new_name)

  local ok, err = vim.uv.fs_rename(old_path, new_path)

  if not ok then
    vim.notify(
      'Failed to rename session: '
        .. old_name
        .. ' -> '
        .. new_name
        .. ': '
        .. err,
      vim.log.levels.ERROR
    )
    return
  end

  vim.api.nvim_exec_autocmds('User', {
    pattern = 'SessionRenamePost',
    modeline = false,
    data = {
      old_name = old_name,
      new_name = new_name,
    },
  })

  rename_lastused(old_name, new_name)
  vim.notify('Session renamed: ' .. old_name .. ' -> ' .. new_name)
end

--- Gets all session names ordered by recency of use.
---
--- Session names ordered from most to least recent use. Sorting fall back to
--- sorting by `mtime` for untracked sessions in the session storage directory.
---
--- @return string[] names Names of all sessions in order.
function M.names()
  local paths = {}

  for filename, type in vim.fs.dir(sessions_dir) do
    if (type == 'file' or type == 'link') and vim.fs.ext(filename) == 'vim' then
      local name = get_name(filename)
      paths[name] = vim.fs.joinpath(sessions_dir, filename)
    end
  end

  local names = {}

  for _, name in ipairs(read_lastused()) do
    if paths[name] then
      names[#names + 1] = name
      paths[name] = nil
    end
  end

  local untracked = {}

  for name, path in pairs(paths) do
    local stat = vim.uv.fs_stat(path)

    untracked[#untracked + 1] = {
      name = name,
      mtime = stat and stat.mtime and stat.mtime.sec or 0,
    }
  end

  table.sort(untracked, function(a, b)
    if a.mtime ~= b.mtime then
      return a.mtime > b.mtime
    end

    return a.name < b.name
  end)

  for _, entry in ipairs(untracked) do
    names[#names + 1] = entry.name
  end

  return names
end

--- Allows the user to save the current session.
---
--- Prompts the creation of a new session if there is no current one.
function M.save_current()
  if vim.v.this_session ~= '' then
    M.save(current())
    return
  end

  new()
end

--- Allows the user to select a session to save to.
---
--- Prompts the user to select a session to save to via `vim.ui.select`. The
--- first option is to create a new session.
function M.save_select()
  local items = M.names()

  table.insert(items, 1, ' Create new session')

  vim.ui.select(
    items,
    { prompt = 'Save or create new session > ' },
    function(choice, idx)
      if not choice then
        vim.notify('Session save canceled.')
        return
      end

      if idx == 1 then
        new()
      else
        M.save(choice)
      end
    end
  )
end

--- Allows the user to select a session to load.
---
--- Prompts the user to select a session to load via `vim.ui.select`.
function M.load_select()
  vim.ui.select(M.names(), { prompt = 'Load session > ' }, function(choice)
    if not choice or choice == '' then
      vim.notify('Session load canceled.')
      return
    end

    M.load(choice)
  end)
end

--- Allows the user to delete current session.
function M.delete_current()
  if vim.v.this_session == '' then
    vim.notify('No current session loaded.')
    return
  end

  M.delete(current())

  vim.v.this_session = ''
end

--- Allows the user to select a session to delete.
---
--- Prompts the user to select a session to delete via `vim.ui.select`.
function M.delete_select()
  vim.ui.select(M.names(), { prompt = 'Delete session > ' }, function(choice)
    if not choice or choice == '' then
      vim.notify('Session delete canceled.')
      return
    end

    M.delete(choice)
  end)
end

--- Allows the user to rename the current session.
---
--- Prompts user to provide a new session name. Handles overwriting if the
--- provided session name is of one that already exists.
function M.rename_current()
  if vim.v.this_session == '' then
    vim.notify('No current session.')
    return
  end

  local old_name = current()

  vim.ui.input({
    prompt = 'Rename current session to: ',
    default = old_name,
  }, function(new_name)
    if not new_name or new_name == '' or new_name == old_name then
      vim.notify('Session rename canceled.')
      return
    end

    local function do_rename(overwrite)
      M.rename(old_name, new_name, overwrite)

      if exists(new_name) then
        vim.v.this_session = get_path(new_name)
      end
    end

    if exists(new_name) then
      confirm_overwrite(new_name, function(overwrite)
        if overwrite then
          do_rename(true)
        else
          vim.notify('Session rename canceled.')
        end
      end)
    else
      do_rename(false)
    end
  end)
end

--- Allows the user to select a session to rename.
---
--- Prompts user to select a session to rename. Handles overwriting if the
--- provided session name is of one that already exists.
function M.rename_select()
  vim.ui.select(M.names(), { prompt = 'Rename session > ' }, function(choice)
    if not choice or choice == '' then
      return
    end

    vim.ui.input({
      prompt = 'Rename "' .. choice .. '" to: ',
      default = choice,
    }, function(new_name)
      if not new_name or new_name == '' or new_name == choice then
        vim.notify('Session rename canceled.')
        return
      end

      local old_path = get_path(choice)
      local new_path = get_path(new_name)

      local function do_rename(overwrite)
        M.rename(choice, new_name, overwrite)
        if vim.v.this_session == old_path and exists(new_name) then
          vim.v.this_session = new_path
        end
      end

      if exists(new_name) then
        confirm_overwrite(new_name, function(overwrite)
          if overwrite then
            do_rename(true)
          else
            vim.notify('Session rename canceled.')
          end
        end)
      else
        do_rename(false)
      end
    end)
  end)
end

--- Sets up session functionality.
function M.setup()
  -- Ensure session storage directory exists.
  --
  -- TODO: Switch this to `vim.fs.mkdir(sessions_dir, { parents = true })` upon
  -- the release of 0.13.
  vim.fn.mkdir(sessions_dir, 'p')

  -- Ensure last-used file exists.
  local f = io.open(lastused_path, 'a')

  if f then
    f:close()
  else
    vim.notify('Failed to create session last-used file.', vim.log.levels.WARN)
  end
end

return M
