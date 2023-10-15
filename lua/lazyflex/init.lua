--[[
This plugin should be the first plugin in the spec list!
--]]

local M = {}

local function get_opts(adapter)
  local opts = adapter.get_opts()
  if opts == nil or type(opts) == "table" and vim.tbl_isempty(opts) then
    return nil -- no opts to work with
  end

  opts = require("lazyflex.config").setup(opts)
  if vim.tbl_isempty(opts.kw) then
    return nil -- no keywords to enable/disable...
  end

  if opts.enable_match then
    opts.kw = vim.list_extend(vim.list_extend({}, opts.kw_always_enable), opts.kw)
  end
  return opts
end

local function attach(opts, adapter)
  require("lazyflex.attach").attach(opts, adapter)
end

local function spec(opts)
  local result = {}
  require("lazyflex.config").for_each_collection(opts, function(mod, mod_config)
    table.insert(result, mod.return_spec(mod_config))
  end)
  return result
end

function M.on_hook(adapter)
  if vim.g.vscode or vim.g.started_by_firenvim then
    return {}
  end

  local opts = get_opts(adapter)
  if opts == nil then
    return {}
  end

  attach({ enable_match = opts.enable_match, kw = opts.kw, override_kw = opts.override_kw }, adapter)

  return spec(opts)
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
