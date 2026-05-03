local M = {}

-- If there are multiple plugins, the ordering of `names` is the order in which
-- the plugins will be loaded
function M.add_names(names, lazy)
  -- Autocmd group name is intentionally left to plugin configuration for to
  -- ensure readability and that naming conventions are followed
  local group = vim.api.nvim_create_augroup(lazy.group_name,
    { clear = true })

  -- Create an automatic command to lazy-load a plugin on a specified event
  vim.api.nvim_create_autocmd(lazy.event, {
    callback = function()
      if type(names) == "string" then
        vim.cmd.packadd(names)
      else
        for _, name in ipairs(names) do
          vim.cmd.packadd(name)
        end
      end
      lazy.config()
    end,
    group = group,
    once = true,
  })
end

-- Boilerplate for lazy-loading a plugin installed through `vim.pack`, wraps
-- add_names
function M.add_spec(spec, lazy)
  -- NOTE: The order of `names` is dependent on vim.pack calling `load` on each
  -- plugin in the same order as each plugin listed in the spec, which is the
  -- case as of now
  -- https://github.com/neovim/neovim/blob/master/runtime/lua/vim/pack.lua
  local names = {}
  vim.pack.add(spec, {
    load = function(plugin)
      table.insert(names, plugin.spec.name)
    end,
  })

  M.add_names(names, lazy)
end

return M
