--[[
 consider two fragments of a plugin, having enabled = false on the second fragment:
 fid 1: { "foo/bar"}
 lazyflex considers "bar" with fid 1 enabled
    it sets cond = false, if should_enable returns false
    or, it does not set a value, if should_enable returns true
 fid 2: { "foo/bar", enabled = false} --> fid1 cond=false must be repaired
--]]

local M = {}

-- when matching, return variable enable_on_match(either false or true)
local function should_enable(name, keywords, enable_on_match)
  name = string.lower(name)
  for _, keyword in ipairs(keywords) do
    if name:find(keyword, 1, true) then
      return enable_on_match
    end
  end
  return not enable_on_match
end

function M.attach(opts, adapter)
  local object_to_attach = adapter.get_object_to_attach()
  local snapshot = object_to_attach.add

  -- each plugin can have multiple fragments, identified by fid
  -- for the same plugin, the add method can be called multiple times:
  object_to_attach.add = function(self, plugin_to_add, ...)
    -- call the original add method:
    local plugin = snapshot(self, plugin_to_add, ...)

    -- when invalid(see lazy.nvim):
    local name = plugin and plugin.name or nil
    if not name then
      return plugin
    end

    -- when unconditionally disabled:
    if plugin.enabled == false then
      -- repair conditionally disabled:
      if plugin.cond == false then
        plugin.cond = true
      end
      return plugin
    end

    -- when enabled:
    if should_enable(name, opts.kw, opts.enable_match) then
      return plugin -- already enabled
    end
    plugin.cond = false
    return plugin
  end
end

return M
