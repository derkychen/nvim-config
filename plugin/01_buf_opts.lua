--- Buffer option setting.
---
--- Configures default buffer options for normal, disk buffers.

--- @type table<integer, boolean>
local opts_initialized = {}

--- Check if default buffer options have been initialized for a buffer.
---
--- @param buf integer Buffer ID.
--- @return boolean initialized Whether buffer options are initialized.
local function is_opts_initialized(buf)
  return opts_initialized[buf] or false
end

--- Mark default buffer options as initialized for a buffer.
---
--- @param buf integer Buffer ID.
local function mark_opts_initialized(buf)
  opts_initialized[buf] = true
end

--- Clear tracking of default buffer options for a buffer.
---
--- @param buf integer Buffer ID.
local function clear_opts_initialized(buf)
  opts_initialized[buf] = nil
end

--- Set the default buffer options.
---
--- @param buf integer Buffer ID.
local function set_default_opts(buf)
  local default_opts_opts = {
    expandtab = true,
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    autoindent = true,
    spelllang = 'en_ca',
    spelloptions = 'camel,noplainbuffer',
  }

  for opt, val in pairs(default_opts_opts) do
    vim.api.nvim_set_option_value(opt, val, { buf = buf, scope = 'local' })
  end
end

--- Set `autocomplete` option as it should adapt connection of LSP clients.
---
--- This allows for `blink.cmp`-like falling back to buffer words for
--- autocompletion when LSP clients are not available.
---
--- @param buf integer Buffer ID.
local function update_autocomplete(buf)
  local has_lsp = #vim.lsp.get_clients({
    bufnr = buf,
    method = 'textDocument/completion',
  }) > 0

  vim.api.nvim_set_option_value('autocomplete', not has_lsp, { buf = buf })
end

local buf_opts_group =
  vim.api.nvim_create_augroup('BufOptions', { clear = true })

-- Set all default buffer options for valid, normal buffers.
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  callback = function(ev)
    local buf = ev.buf

    if not is_opts_initialized(buf) then
      set_default_opts(buf)
      mark_opts_initialized(buf)
    end

    update_autocomplete(buf)
  end,
  group = buf_opts_group,
})

-- Clean `opts_initialized` table on the closing of buffers.
vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufDelete' }, {
  callback = function(ev)
    clear_opts_initialized(ev.buf)
  end,
  group = buf_opts_group,
})

-- Refresh `autocomplete` option.
vim.api.nvim_create_autocmd({ 'BufEnter', 'LspAttach', 'LspDetach' }, {
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        update_autocomplete(ev.buf)
      end
    end)
  end,
  group = buf_opts_group,
})
