local function set_default_buflocal_opts(buf)
  local default_buflocal_opts = {
    expandtab = true,                     -- Convert tabs to spaces
    tabstop = 2,                          -- Columns per tab
    softtabstop = 2,                      -- Columns per soft tab stop
    shiftwidth = 2,                       -- Columns per indentation level
    autoindent = true,                    -- Copy previous indent on new line
    spelllang = "en_ca",                  -- Spelling language and locale
    spelloptions = "camel,noplainbuffer", -- Handle camel casing and syntax
  }

  for opt, val in pairs(default_buflocal_opts) do
    vim.api.nvim_set_option_value(opt, val, { buf = buf, scope = "local" })
  end
end

-- Track buffers whose default local options have been set
local buflocal_initialized = {}

local function mark_buflocal_initialized(buf)
  buflocal_initialized[buf] = true
end

local function is_buflocal_initialized(buf)
  return buflocal_initialized[buf] or false
end

local function clear_buflocal_initialized(buf)
  buflocal_initialized[buf] = nil
end

local buflocal_opts_group = vim.api.nvim_create_augroup("BufLocalOptions",
  { clear = true })

-- Set all default buffer-local options for valid, normal buffers
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  callback = function(ev)
    local buf = ev.buf
    if not is_buflocal_initialized(buf) then
      set_default_buflocal_opts(buf)
      mark_buflocal_initialized(buf)
    end
  end,
  group = buflocal_opts_group,
})

-- Clean `buflocal_initialized` and winlocal_initialized` tables on the closing
-- of buffers
vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
  callback = function(ev)
    clear_buflocal_initialized(ev.buf)
  end,
  group = buflocal_opts_group,
})
