local M = {}

-- see lazyflex.adapter.lazy: replace lazy.nvim
function M.fake_lazy(opts, spec)
  return {
    get_opts = function()
      return opts
    end,
    add = function(lazyflex_add)
      -- simulate lazy.nvim parsing the spec
      for _, plugin in ipairs(spec) do
        lazyflex_add(_, plugin)
      end
    end,
  }
end

-- run lazyflex. See lazyflex.hook
function M.activate(opts, spec, collection_names)
  local lazy = M.fake_lazy(opts, spec)

  if not collection_names then
    collection_names = { "lazyvim", "user" }
  end
  return require("lazyflex").on_hook(lazy, collection_names)
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
