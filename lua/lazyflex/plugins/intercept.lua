---@diagnostic disable: duplicate-set-field

if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local Config = require("lazyflex.config")
local opts = Config.setup()
local match = require("lazyflex.core").match

local Plugin = require("lazy.core.plugin")
local add = Plugin.Spec.add

Plugin.Spec.add = function(self, plugin, ...)
  local added = add(self, plugin, ...)

  local name = added and added.name or nil
  if not name then
    return added
  end

  added[opts.target_property] = match(name, opts.keywords, opts.enable_on_match)
  return added
end

local result = {}
Config.for_each_collection(opts, function(mod, config)
  table.insert(result, mod.return_spec(config))
end)
return result
