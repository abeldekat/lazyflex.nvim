local M = {}

local containers = {
  lazyvim = function()
    return require("lazyflex.presets.lazyvim")
  end,
}

M.factory = function(name)
  local module = containers[name]
  return module and module() or require("lazyflex.presets.dummy")
end

return M
