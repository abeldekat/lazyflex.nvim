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
  if vim.tbl_isempty(opts.kw) and not opts.filter_modules.enabled then
    return nil -- nothing to do
  end
  return opts
end

local function filter_modules(opts, adapter)
  if opts.filter_modules.enabled then
    local opts_modules = { filter_modules = opts.filter_modules }
    require("lazyflex.modules").filter(opts_modules, adapter)
  end
end

local function plugins(opts, adapter)
  if not vim.tbl_isempty(opts.kw) then
    local opts_plugin = {
      enable_match = opts.enable_match,
      kw = opts.kw,
      override_kw = opts.override_kw,
    }
    require("lazyflex.plugin").intercept(opts_plugin, adapter)
  end
end

local function settings(opts)
  local spec = {}
  for _, change_settings in pairs(opts.collections) do
    table.insert(spec, change_settings() or {})
  end
  return spec
end

function M.on_hook(adapter)
  -- don't use when embedded
  if vim.g.vscode or vim.g.started_by_firenvim then
    return {}
  end

  local opts = get_opts(adapter)
  if opts == nil then
    return {} -- opt-out early
  end

  filter_modules(opts, adapter)
  plugins(opts, adapter)
  return settings(opts)
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
