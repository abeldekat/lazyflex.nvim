local M = {}

local function match(name, keywords, enable_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_match
    end
  end
  return not enable_match
end

local function override_disabled(plugin)
  -- disabled plugin: using enabled = false explicitly:
  -- fid 1: { "foo/bar"}
  --> lazyflex considers "bar" with fid 1 enabled and:
  --   sets cond = false, if match returns false
  --   or
  --   does not set a value, if match returns true
  -- fid 2: { "foo/bar", enabled = false}

  if plugin.cond == false then
    -- must override, otherwise the plugin will always be conditional
    plugin.cond = true
  end
  return plugin
end

function M.attach(opts, adapter)
  local target = adapter.get_target()
  local snapshot = target.add

  target.add = function(self, plugin, ...)
    local plugin_to_use = snapshot(self, plugin, ...)

    local name = plugin_to_use and plugin_to_use.name or nil

    -- lazy.nvim marks this as invalid:
    if not name then
      return plugin_to_use
    end

    -- disabled plugin: using enabled = false explicitly:
    if plugin_to_use.enabled == false then
      plugin_to_use = override_disabled(plugin_to_use)
      return plugin_to_use
    end

    -- enabled plugin: do not set a superfluous cond property
    local match_result = match(name, opts.kw, opts.enable_match)
    if match_result then
      return plugin_to_use
    end

    -- enabled plugin: must be disabled
    plugin_to_use.cond = false
    return plugin_to_use
  end
end

return M
