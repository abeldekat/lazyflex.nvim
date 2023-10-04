--[[
deprecated, keep for reference
overwrites the default cond function.
less powerful, plugins can define their own cond function...

use intercept.lua, per plugin, the target property can also be selected
--]]

if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local Config = require("lazyflex.config")
local opts = Config.setup()
local match = require("lazyflex.core").match

require("lazy.core.config").options.defaults.cond = function(plugin)
  return match(plugin.name, opts.keywords, opts.enable_on_match)
end

local result = {}
Config.for_each_collection(opts, function(mod, config)
  table.insert(result, mod.return_spec(config))
end)
return result
