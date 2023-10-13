local M = {}

-- see lazyflex.adapter.lazy: simulate the interaction with lazy.nvim
function M.fake_lazy(opts, to_attach)
  return {
    get_opts = function()
      return opts
    end,
    get_object_to_attach = function()
      return to_attach
    end,
  }
end

function M.activate(opts, spec)
  -- simulate lazy.nvim internals(adapter)
  local lazy_attached = {
    add = function(_, plugin)
      -- lazy.nvim adds and returns the plugin...
      return plugin
    end,
  }
  local lazy = M.fake_lazy(opts, lazy_attached)

  -- run lazyflex. See lazyflex.hook. Decorates lazy_attached.add
  local return_spec = require("lazyflex").on_hook(lazy)

  -- lazy.nvim parses the spec
  for _, plugin in ipairs(spec) do
    lazy_attached.add(_, plugin)
  end
  return return_spec
end

-- filters the spec using plugin.cond==enable_match
local function filter_actual(spec, enable_match)
  local result = {}
  for _, plugin in ipairs(spec) do
    if plugin.cond == enable_match then
      table.insert(result, plugin.name)
    end
  end
  return result
end

function M.filter_disabled(spec)
  return filter_actual(spec, false)
end

function M.filter_not_modified(spec)
  return filter_actual(spec, nil)
end
return M
