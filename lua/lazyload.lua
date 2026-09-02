---Single plugin lazy-loading functionality.
---
---Handles automatic command boilerplate for registration of lazy plugins.
local M = {}

---@class LazySpec
---@field augroup_name string Automatic command group name for plugin loading.
---@field events string|string[] Event(s) on which to load the plugin.
---@field name string Name of the plugin used on loading.
---@field config fun() Configuration function for the plugin.

---Register a plugin to lazy-load.
---
---Creates automatic commands for loading the plugin on specified events. These
---are only added once.
---
---@param spec LazySpec Lazy plugin spec.
function M.register(spec)
  local group = vim.api.nvim_create_augroup(spec.augroup_name, { clear = true })

  vim.api.nvim_create_autocmd(spec.events, {
    callback = vim.schedule_wrap(function()
      vim.cmd.packadd(spec.name)
      vim.schedule(spec.config)
      vim.api.nvim_del_augroup_by_id(group)
    end),
    group = group,
    once = true,
  })
end

return M
