local M = {}

-- Automatic command to lazy-load a plugin on a specified event
function M.lazyadd(names, lazy_plugin)
  -- Autocmd group name is intentionally left to plugin configuration for
  -- readability
  local group = vim.api.nvim_create_augroup(lazy_plugin.group_name,
    { clear = true })

  vim.api.nvim_create_autocmd(lazy_plugin.event, {
    callback = function()
      if type(names) == "string" then
        vim.cmd.packadd(names)
      else
        for _, name in pairs(names) do
          vim.cmd.packadd(name)
        end
      end
      lazy_plugin.config()
    end,
    group = group,
    once = true,
  })
end

-- Boilerplate for lazy-loading a plugin installed through `vim.pack`
function M.vimpack_lazyadd(lazy_plugin)
  -- Resolve all plugin names
  local names = {}
  vim.pack.add(lazy_plugin.spec, {
    load = function(plugin)
      table.insert(names, plugin.spec.name)
    end,
  })

  M.lazyadd(names, lazy_plugin)
end

return M
