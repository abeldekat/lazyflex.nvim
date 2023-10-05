--[[
deprecated, keep for reference
overwrites the default cond function.
less powerful, plugins can define their own cond function...

use intercept.lua, per plugin, the target property can also be selected
--]]
if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end

local LazyConfig = require("lazy.core.config")
local lazyflex_plugin = LazyConfig.spec.plugins["lazyflex.nvim"]
local opts = lazyflex_plugin.opts
if opts == nil or type(opts) == "table" and vim.tbl_isempty(opts) then
  return {}
end

local Config = require("lazyflex.config")
opts = Config.setup(opts)

local match = require("lazyflex.core").match
LazyConfig.options.defaults.cond = function(plugin)
  return match(plugin.name, opts.keywords, opts.enable_on_match)
end

local result = {}
Config.for_each_collection(opts, function(mod, config)
  table.insert(result, mod.return_spec(config))
end)
return result
