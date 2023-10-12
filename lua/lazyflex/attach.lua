local M = {}

-- return the value of enable_match when there is a match
local function should_enable(name, keywords, enable_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_match
    end
  end
  return not enable_match
end

-- each plugin can have multiple fragments, identified by fid
-- for the same plugin, the add method can be called multiple times:
function M.attach(opts, adapter)
  local object_to_attach = adapter.get_object_to_attach()
  local snapshot = object_to_attach.add

  object_to_attach.add = function(self, plugin_to_add, ...)
    -- call the original add method:
    local plugin = snapshot(self, plugin_to_add, ...)

    -- when invalid(see lazy.nvim):
    local name = plugin and plugin.name or nil
    if not name then
      return plugin
    end

    -- when unconditionally disabled:
    if plugin.enabled == false then
      -- see unit test: "is repaired when cond=false"
      if plugin.cond == false then -- repair
        plugin.cond = true
      end
      return plugin
    end

    -- plugin is enabled:
    if not should_enable(name, opts.kw, opts.enable_match) then
      plugin.cond = false
    end
    return plugin
  end
end

return M
