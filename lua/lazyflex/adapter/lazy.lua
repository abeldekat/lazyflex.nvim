--[[
Provides a central place in the code where lazy.nvim is used

inversion of control pattern
important benefit: testing...
- Making sure the integration works -> see e2e_spec.lua
- Making sure lazyflex works -> see unit test specs
--]]
local M = {}

function M.get_opts()
  local lazyflex_plugin = require("lazy.core.config").spec.plugins["lazyflex.nvim"]
  return lazyflex_plugin.opts
end

function M.get_target()
  return require("lazy.core.plugin").Spec
end

function M.get_property_to_decorate()
  return "add"
end

return M
