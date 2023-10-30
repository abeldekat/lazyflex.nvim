local M = {}

local defaults = {

  -- when enabled: only import a selection of the modules in use
  filter_modules = {
    enabled = false,
    kw = {}, -- contains keywords for module names to import
    always_import = {}, -- always contains "lazyvim.plugins" and "plugins"
  },

  lazyvim = {
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    settings = {
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  user = {

    -- optional: functions implementing presets and change_settings
    get_preset_keywords = nil,
    change_settings = nil,

    presets = {}, -- example, when implemented: { "editor" }

    settings = { -- passed into function change_settings:
      enabled = true, -- quick switch. Disables the three options below:
      options = true,
      autocmds = true,
      keymaps = true,
    },
  },

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords matching plugins to always enable:
  kw_always_enable = {}, -- the "lazy" keyword is always included

  -- keywords matching plugins, as specified by the user:
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- when the name of a plugin is matched and also has a match in override_kw:
  -- invert enable_match for that plugin
  override_kw = {},
}

local handlers = {
  lazyvim = function(_)
    local mod = require("lazyflex.collections.lazyvim")
    return {
      get_preset_keywords = mod.get_preset_keywords,
      change_settings = mod.change_settings,
    }
  end,
  user = function(user)
    return {
      get_preset_keywords = user.get_preset_keywords or function()
        return {}
      end,
      change_settings = user.change_settings or function()
        return {}
      end,
    }
  end,
}

local function sanitize_settings(settings)
  local result = settings
  if not result then
    result = { enabled = true }
  end
  if not result.enabled then
    result.options = false
    result.autocmds = false
    result.keymaps = false
  end
  return result
end

local function sanitize_filter_modules(filter_modules)
  if not filter_modules.enabled then
    return filter_modules
  end

  if not filter_modules.kw then
    filter_modules.kw = {}
  end

  if not vim.tbl_contains(filter_modules.always_import, "lazyvim.plugins") then
    table.insert(filter_modules.always_import, "lazyvim.plugins")
  end
  if not vim.tbl_contains(filter_modules.always_import, "plugins") then
    table.insert(filter_modules.always_import, "plugins")
  end
  filter_modules.kw = vim.tbl_map(string.lower, filter_modules.kw)
  filter_modules.always_import = vim.tbl_map(string.lower, filter_modules.always_import)
  return filter_modules
end

local function sanitize_always_enable(kw_always_enable)
  local always_enable = kw_always_enable or {}
  if not vim.tbl_contains(always_enable, "lazy") then
    table.insert(always_enable, "lazy")
  end
  return always_enable
end

local function to_kw(get_preset_keywords, presets, enable_match)
  local keywords = {}
  if vim.tbl_isempty(presets) then
    return keywords
  end

  for _, preset in ipairs(presets) do
    keywords = vim.list_extend(keywords, get_preset_keywords(preset, enable_match))
  end
  return keywords
end

local function transform(opts_supplied, opts_merged)
  local opts = {}

  opts.filter_modules = sanitize_filter_modules(opts_merged.filter_modules)
  opts.enable_match = opts_merged.enable_match
  opts.collections = {} -- key: name, value: function
  opts.kw = {}

  for name, handler_func in pairs(handlers) do
    if opts_supplied[name] then -- the collection is configured
      local collection = opts_merged[name]
      local settings = sanitize_settings(collection.settings)
      local handler = handler_func(collection)
      opts.collections[name] = function()
        return handler.change_settings(settings)
      end
      local presets_kw = to_kw(handler.get_preset_keywords, collection.presets, opts.enable_match)
      opts.kw = vim.list_extend(opts.kw, presets_kw)
    end
  end

  -- add keywords supplied by user
  local user_kw = opts_merged.kw and vim.tbl_map(string.lower, opts_merged.kw) or {}
  opts.kw = vim.list_extend(opts.kw, user_kw)
  opts.override_kw = opts_merged.override_kw and vim.tbl_map(string.lower, opts_merged.override_kw) or {}

  return opts
end

M.setup = function(opts_supplied)
  local opts_merged = vim.tbl_deep_extend("force", defaults, opts_supplied or {}) or {}
  local opts = transform(opts_supplied, opts_merged)

  -- when there are keywords, also add kw_always_enable if enable_match==true
  if not vim.tbl_isempty(opts.kw) then
    if opts.enable_match then
      local enable = sanitize_always_enable(opts_merged.kw_always_enable) or {}
      opts.kw = vim.list_extend(vim.list_extend({}, enable), opts.kw)
    end
  end
  return opts
end

return M
