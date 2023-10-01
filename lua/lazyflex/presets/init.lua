local M = {}

-- a dummy implementation for a "preset" module
local Dummy = {}
Dummy.get_preset_keywords = function(_, _)
  return {}
end
Dummy.intercept_options = function(_) end
Dummy.return_container_spec = function(_)
  return {}
end

local containers = {
  lazyvim = function()
    return require("lazyflex.presets.lazyvim")
  end,
}

M.factory = function(name)
  local module = containers[name]
  return module and module() or Dummy
end

return M
