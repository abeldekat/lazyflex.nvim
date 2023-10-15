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

local function attach(opts, adapter)
  require("lazyflex.attach").attach(opts, adapter)
end

local function change_settings(opts, collection_names)
  local result = {}
  for _, name in ipairs(collection_names) do
    local c = opts[name]
    if c then
      table.insert(result, c.change_settings(c.settings))
    end
  end
  return result
end

function M.on_hook(adapter, collection_names)
  if vim.g.vscode or vim.g.started_by_firenvim then
    return {}
  end

  local opts = get_opts(adapter, collection_names)
  if opts == nil then
    return {}
  end

  attach(opts, adapter)

  return change_settings(opts, collection_names)
end

function M.setup(_)
  -- dummy: invoked to late in the process..
end

return M
