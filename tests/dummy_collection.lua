-- a stub implementation for a "collection" module
-- pass-through...
local M = {}

M.get_preset_keywords = function(_, _) -- name, enable_match
  return {}
end

-- only to be used in unit test
-- returns a dummy spec, using the options in config
M.change_settings = function(config) -- config
  local result = {
    "foo/bar",
    opts = config,
  }
  return result
end

return M
