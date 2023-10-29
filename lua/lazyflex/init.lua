--[[
This plugin should be the first plugin in the spec list!
--]]

local M = {}

local function get_opts(adapter, collection_names)
  local opts = adapter.get_opts()
  if opts == nil or type(opts) == "table" and vim.tbl_isempty(opts) then
    return nil -- no opts to work with
  end

  opts = require("lazyflex.config").setup(opts, collection_names)
  if vim.tbl_isempty(opts.kw) and not opts.filter_import.enabled then
    return nil -- nothing to do
  end
  return opts
end

local function filter_import(opts, adapter)
  if opts.filter_import.enabled then
    local opts_import = { filter_import = opts.filter_import }
    require("lazyflex.import").filter(opts_import, adapter)
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

local function settings(opts, collection_names)
  local spec = {}
  for _, name in ipairs(collection_names) do
    local c = opts[name]
    if c then
      table.insert(spec, c.change_settings(c.settings) or {})
    end
  end
  return spec
end

function M.on_hook(adapter, collection_names)
  -- don't use when embedded
  if vim.g.vscode or vim.g.started_by_firenvim then
    return {}
  end

  local opts = get_opts(adapter, collection_names)
  if opts == nil then
    return {} -- opt-out early
  end

  filter_import(opts, adapter)
  plugins(opts, adapter)
  return settings(opts, collection_names)
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
