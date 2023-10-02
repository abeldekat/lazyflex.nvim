-- a dummy implementation for a "preset" module
local Dummy = {}

Dummy.get_preset_keywords = function(_, _)
  return {}
end

Dummy.intercept_options = function(_) end

Dummy.return_container_spec = function(_)
  return {}
end

return Dummy
