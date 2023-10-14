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

local function is_optional_in_core(plugin)
  -- when a plugin is removed from core,
  -- plugin.optional and plugin.enabled are used to inform the user
  if plugin.optional == true then
    return plugin._.module and not plugin._.module:find("lazyvim.plugins.extras")
  end
  return false
end

-- cond and enabled can be a function
local function get_value(prop_or_function, plugin)
  if type(prop_or_function) == "function" then
    return prop_or_function(plugin)
  end
  return prop_or_function
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
    if get_value(plugin.enabled, plugin) == false then
      -- see unit test: "is repaired when cond=false"
      if get_value(plugin.cond, plugin) == false then
        plugin.cond = true -- repair
      end
      return plugin
    end

    -- plugin is enabled:
    local is_found = find(name, opts.kw)
    plugin.cond = is_found and opts.enable_match
    if is_found and is_also_found_in(name, opts.override_kw) then
      plugin.cond = not plugin.cond -- override
    end

    return plugin
  end
end

return M
