local M = {}

-- cond and enabled can be a function
local function get_value(prop_or_function, plugin)
  if type(prop_or_function) == "function" then
    return prop_or_function(plugin)
  end
  return prop_or_function
end

-- return the value of enable_match when there is a match
local function should_enable(name, keywords, enable_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_match
    end
  end
  return not enable_match
end

-- invert the value of enable_match for plugins that match keywords in `kw_invert`
local function should_invert(name, keywords)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return true
    end
  end
  return false
end

local function is_optional_in_core(plugin)
  -- when a plugin is removed from core,
  -- plugin.optional and plugin.enabled are used to inform the user
  if plugin.optional == true then
    return plugin._.module and not plugin._.module:find("lazyvim.plugins.extras")
  end
  return false
end

-- each plugin can have multiple fragments, identified by fid
-- for the same plugin, the add method can be called multiple times:
function M.attach(opts, adapter)
  local object_to_attach = adapter.get_object_to_attach()
  local add = object_to_attach.add

  object_to_attach.add = function(self, plugin_to_add, ...)
    -- call lazy's add
    local plugin = add(self, plugin_to_add, ...)

    -- when invalid(see lazy.nvim):
    local name = plugin and plugin.name or nil
    if not name then
      return plugin
    end
    -- when optional in core:
    if is_optional_in_core(plugin) then
      return plugin
    end

    -- when unconditionally disabled:
    local plugin_enabled = get_value(plugin.enabled, plugin)
    if plugin_enabled == false then
      -- see unit test: "is repaired when cond=false"
      if get_value(plugin.cond, plugin) == false then
        plugin.cond = true -- repair
      end
      return plugin
    end

    -- plugin is enabled:
    plugin.cond = should_enable(name, opts.kw, opts.enable_match)
    if opts.kw_invert and not vim.tbl_isempty(opts.kw_invert) then
      local invert = should_invert(name, opts.kw_invert)
      if invert then
        plugin.cond = not opts.enable_match
      end
    end

    return plugin
  end
end

return M
