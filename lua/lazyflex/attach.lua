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

function M.attach(opts, adapter)
  local target = adapter.get_target()
  local property_to_decorate = adapter.get_property_to_decorate()
  local snapshot = target[property_to_decorate]

  target[property_to_decorate] = function(self, plugin, ...)
    local plugin_to_use = snapshot(self, plugin, ...)

    local name = plugin_to_use and plugin_to_use.name or nil
    if not name then
      return plugin_to_use
    end

    plugin_to_use.cond = match(name, opts.kw, opts.enable_match)
    return plugin_to_use
  end
end

-- deprecated: less powerful: plugins can define their own cond function...
-- uncomment to compare:
-- function M.attach(opts, _)
--   local LazyConfig = require("lazy.core.config")
--   LazyConfig.options.defaults.cond = function(plugin)
--     return match(plugin.name, opts.kw, opts.enable_match)
--   end
-- end

return M
