local M = {}

local containers = {
  lazyvim = function()
    return require("lazyflex.containers.lazyvim")
  end,
  user = function()
    return require("lazyflex.containers.stub")
  end,
}

M.factory = function(opts)
  local name = opts.container.enabled and opts.container.name or "user"
  local container = containers[string.lower(name)]
  if not container then
    container = containers["user"]
  end
  return container()
end

return M
