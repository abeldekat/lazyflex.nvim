local M = {}

local function override_cond_if_false(plugin_enabled_false)
  -- cnosidera plugin, having enabled = false explicitly:
  -- fid 1: { "foo/bar"}
  -- lazyflex considers "bar" with fid 1 enabled
  --    set cond = false, if should_enable returns false
  --    or, do not set a value, if should_enable returns true
  -- fid 2: { "foo/bar", enabled = false} --> fid1 must be overridden

  if plugin_enabled_false.cond == false then
    -- prevent a disabled plugin to become conditionally disabled:
    plugin_enabled_false.cond = true
  end
  return plugin_enabled_false
end

-- on match, return variable enable_on_match(either false or true)
local function should_enable(name, keywords, enable_on_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_on_match
    end
  end
  return not enable_on_match
end

function M.attach(opts, adapter)
  local object_to_attach = adapter.get_object_to_attach()
  local snapshot = object_to_attach.add

  -- each plugin can have multiple fragments, identified by fid
  -- for the same plugin, this method can be called multiple times
  object_to_attach.add = function(self, plugin, ...)
    -- call the original add method:
    local plugin_to_use = snapshot(self, plugin, ...)

    -- return when invalid(see lazy.nvim):
    local name = plugin_to_use and plugin_to_use.name or nil
    if not name then
      return plugin_to_use
    end

    -- return when plugin is disabled(using enabled = false explicitly):
    if plugin_to_use.enabled == false then
      plugin_to_use = override_cond_if_false(plugin_to_use)
      return plugin_to_use
    end

    -- return when plugin should be enabled:
    local enable = should_enable(name, opts.kw, opts.enable_match)
    if enable then
      return plugin_to_use -- already enabled
    end

    -- plugin needs to be disabled:
    plugin_to_use.cond = false
    return plugin_to_use
  end
end

return M
