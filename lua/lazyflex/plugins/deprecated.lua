--[[
deprecated, but keep for now
use intercept.lua
--]]
if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local opts = require("lazyflex.config").setup()
local cond = require("lazyflex.utils").cond

require("lazy.core.config").options.defaults.cond = function(plugin)
  return cond(plugin.name, opts)
end

local preset = require("lazyflex.presets").factory(opts.plugin_container)
preset.intercept_options(opts)
return preset.return_container_spec(opts)
