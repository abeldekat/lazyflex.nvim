--[[
deprecated, keep for reference
overwrites the default cond function.
less powerful, plugins can define their own cond function...

use intercept.lua, per plugin, the target property can also be selected
--]]
if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local opts = require("lazyflex.config").setup()
local cond = require("lazyflex.utils").cond

require("lazy.core.config").options.defaults.cond = function(plugin)
  return cond(plugin.name, opts)
end

local container = require("lazyflex.container").factory(opts)
container.intercept_options(opts)
return container.return_container_spec(opts)
