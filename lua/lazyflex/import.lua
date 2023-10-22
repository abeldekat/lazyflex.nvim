local M = {}

-- return true when name equals any of the modnames
local function is_equal(name, modnames)
  for _, modname in ipairs(modnames) do
    if name == modname then
      return true
    end
  end
  return false
end

-- return true when name matches any of the keywords
local function find(name, keywords)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return true
    end
  end
  return false
end

function M.filter(opts, adapter)
  adapter.import(function(_, spec)
    local result = is_equal(spec.import, opts.filter_import.always_import)
    if not result then
      result = find(spec.import, opts.filter_import.kw)
    end
    return result
  end)
end

return M
