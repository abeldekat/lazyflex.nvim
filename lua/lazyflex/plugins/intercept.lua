---@diagnostic disable: duplicate-set-field
if vim.g.vscode or vim.g.started_by_firenvim then
  return {}
end
local lazyflex_plugin = require("lazy.core.config").spec.plugins["lazyflex.nvim"]
local opts = lazyflex_plugin.opts

if opts == nil or type(opts) == "table" and vim.tbl_isempty(opts) then
  return {} -- no opts to work with...
end

local Config = require("lazyflex.config")
opts = Config.setup(opts)
if vim.tbl_isempty(opts.keywords) then
  return {} -- no keywords to enable/disable...
end
if opts.enable_on_match then
  opts.keywords = vim.list_extend(vim.list_extend({}, opts.keywords_to_always_enable), opts.keywords)
end

local LazyPlugin = require("lazy.core.plugin")
local add = LazyPlugin.Spec.add
local match = require("lazyflex.core").match
LazyPlugin.Spec.add = function(self, plugin, ...)
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
