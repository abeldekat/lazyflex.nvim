local M = {}

local Dummy = {}
Dummy.get = function(_, _)
  -- for now, return dummy collecton if the requested collection is not present.
  return {}
end

local collections = {
  lazyvim = function()
    return require("lazyflex.presets.lazyvim")
  end,
}

M.from_collection = function(name_of_collection)
  local collection = collections[name_of_collection]
  return collection and collection() or Dummy
end

return M
