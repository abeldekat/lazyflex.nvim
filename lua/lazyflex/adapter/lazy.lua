--[[
Provides a central place in the code where lazy.nvim is used

inversion of control pattern
important benefit: testing...
- Making sure the integration works -> see e2e_spec.lua
- Making sure lazyflex works -> see unit test specs
--]]
local M = {}

-- Returns the opts the user configured for lazyflex.nvim
function M.get_opts()
  local lazyflex_plugin = require("lazy.core.config").spec.plugins["lazyflex.nvim"]
  local opts = lazyflex_plugin.opts or {}

  if type(opts) == "function" then
    return opts(lazyflex_plugin, {})
  end
  return opts
end

-- Returns the object in lazy.nvim holding the add method
function M.get_object_to_attach()
  return require("lazy.core.plugin").Spec
end

return M
