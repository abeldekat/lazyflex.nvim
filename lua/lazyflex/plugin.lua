local M = {}

local function find(name, keywords)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return true
    end
  end
  return false
end

local function is_also_found_in(name, keywords)
  return keywords and not vim.tbl_isempty(keywords) and find(name, keywords)
end

local function is_optional(plugin)
  -- when a plugin is removed from core,
  -- plugin.optional and plugin.enabled=false are used to inform the user
  return plugin.optional
end

-- cond and enabled can be a function
local function get_value(prop_or_function, plugin)
  if type(prop_or_function) == "function" then
    return prop_or_function(plugin)
  end
  return prop_or_function
end

local function calculate_cond(name, opts)
  local cond = false
  if not find(name, opts.kw) then
    cond = not opts.enable_match
  else
    cond = opts.enable_match
    if is_also_found_in(name, opts.override_kw) then
      cond = not cond
    end
  end
  return cond
end

-- each plugin can have multiple fragments, identified by fid
-- for the same plugin, the add method can be called multiple times:
function M.intercept(opts, adapter)
  adapter.add(function(_, plugin)
    -- when invalid(see lazy.nvim):
    local name = plugin and plugin.name and string.lower(plugin.name) or nil
    if not name then
      return plugin
    end

    -- when optional
    if is_optional(plugin) then
      return plugin
    end

    -- when unconditionally disabled:
    if get_value(plugin.enabled, plugin) == false then
      -- see unit test: "is repaired when cond=false"
      if get_value(plugin.cond, plugin) == false then
        plugin.cond = true -- repair
      end
      return plugin
    end

    -- plugin is enabled:
    plugin.cond = calculate_cond(name, opts)
    return plugin
  end)
end

return M
