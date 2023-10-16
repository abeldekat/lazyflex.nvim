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
  if vim.tbl_isempty(opts.kw) then
    return nil -- no keywords to enable/disable...
  end

  return opts
end

function M.on_hook(adapter, collection_names)
  -- don't use when embedded
  if vim.g.vscode or vim.g.started_by_firenvim then
    return {}
  end

  -- opts
  local opts = get_opts(adapter, collection_names)
  if opts == nil then
    return {}
  end

  -- keywords
  local opts_attach = {
    enable_match = opts.enable_match,
    kw = opts.kw,
    override_kw = opts.override_kw,
  }
  require("lazyflex.attach").attach(opts_attach, adapter)

  -- settings
  local result = {}
  for _, name in ipairs(collection_names) do
    local c = opts[name]
    if c then
      local spec = c.change_settings(c.settings)
      table.insert(result, spec)
    end
  end
  return result
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
