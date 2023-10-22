local M = {}

local defaults = {
  -- lazyvim collection
  lazyvim = {
    -- any lazyvim.presets specified that don't match have no effect:
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    -- load lazyvim's settings by default:
    settings = {
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user collection
  user = {
    -- lazyflex.collections.stub is used by default as a pass-through

    -- 1. optional: functions overriding lazyflex.collections.stub
    get_preset_keywords = nil,
    change_settings = nil,

    -- 2. optional: a user module, "required" automatically
    -- the module should contain an implementation of lazyflex.collections.stub
    -- use lazyflex.collections.lazyvim as an example
    mod = "config.lazyflex",

    presets = {}, -- example, when implemented: { "editor" }

    settings = { -- passed into function change_settings:
      enabled = true, -- quick switch. Disables the three options below:
      options = true,
      autocmds = true,
      keymaps = true,
    },
  },

  filter_import = {
    enabled = false, -- when enabled and kw is empty: skips all extra imports
    -- always import the following modnames:
    always_import = {}, -- contains "lazyvim.plugins" and "plugins" by default
    -- only import when the name matches a keyword in kw:
    kw = {}, -- { "python", "black" } only imports python modules(ie from lazyvim extras)
  },

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords matching plugins to always enable:
  kw_always_enable = {}, -- the "lazy" keyword is always included

  -- keywords specified by the user:
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- when the name of the plugin matches keywords in both kw/preset and override_kw:
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
  user = function(collection)
    local mod = nil
    if not (collection.get_preset_keywords or collection.change_settings) then
      local ok, usermod = pcall(require, collection.mod)
      if ok then
        mod = usermod
      else
        mod = require("lazyflex.collections.stub")
      end
    end
    return {
      get_preset_keywords = collection.get_preset_keywords or mod and mod.get_preset_keywords,
      change_settings = collection.change_settings or mod and mod.change_settings,
    }
  end,
}

local function sanitize_settings(config)
  local result = config
  if not result then
    result = { enabled = false }
  end
  if not result.enabled then
    result.options = false
    result.autocmds = false
    result.keymaps = false
  end
  return result
end

local function sanitize_filter_import(filter_import)
  if not filter_import.enabled then
    return filter_import
  end

  if not filter_import.kw then
    filter_import.kw = {}
  end

  if not vim.tbl_contains(filter_import.always_import, "lazyvim.plugins") then
    table.insert(filter_import.always_import, "lazyvim.plugins")
  end
  if not vim.tbl_contains(filter_import.always_import, "plugins") then
    table.insert(filter_import.always_import, "plugins")
  end
  filter_import.kw = vim.tbl_map(string.lower, filter_import.kw)
  filter_import.always_import = vim.tbl_map(string.lower, filter_import.always_import)
  return filter_import
end

local function sanitize_always_enable(kw_always_enable)
  local always_enable = kw_always_enable or {}
  if not vim.tbl_contains(always_enable, "lazy") then
    table.insert(always_enable, "lazy")
  end
  return always_enable
end

local function to_kw(handler, presets, enable_match)
  local keywords = {}
  if vim.tbl_isempty(presets) then
    return keywords
  end

  for _, preset in ipairs(presets) do
    keywords = vim.list_extend(keywords, handler.get_preset_keywords(preset, enable_match))
  end
  return keywords
end

local function transform(collection_names, opts_supplied)
  local opts = {}

  opts["filter_import"] = sanitize_filter_import(opts_supplied.filter_import)
  opts["enable_match"] = opts_supplied.enable_match
  opts["kw"] = {}
  opts["override_kw"] = {}

  for _, name in ipairs(collection_names) do
    local c = opts_supplied[name] -- the supplied options of the collection
    if c then
      -- the handler has functions for presets and settings
      local handler = handlers[name](c)
      -- settings: add the settings and the corresponding handler
      opts[name] = {
        settings = sanitize_settings(c.settings),
        change_settings = handler.change_settings,
      }
      -- presets: add all keywords found in the presets of the collection
      opts.kw = vim.list_extend(opts.kw, to_kw(handler, c.presets, opts.enable_match))
    end
  end

  -- add keywords supplied by user
  local user_kw = opts_supplied.kw and vim.tbl_map(string.lower, opts_supplied.kw) or {}
  opts.kw = vim.list_extend(opts.kw, user_kw)
  opts.override_kw = opts.override_kw and vim.tbl_map(string.lower, opts_supplied.override_kw) or {}

  return opts
end

M.setup = function(opts_supplied, collection_names)
  -- merge with defaults
  local supplied = vim.tbl_deep_extend("force", defaults, opts_supplied or {})

  -- sanitze opts and resolve presets into keywords
  local opts = transform(collection_names, supplied)

  -- when there are keywords, also add kw_always_enable if enable_match==true
  if not vim.tbl_isempty(opts.kw) then
    if opts.enable_match then
      local always_enable = supplied and sanitize_always_enable(supplied.kw_always_enable) or {}
      opts.kw = vim.list_extend(vim.list_extend({}, always_enable), opts.kw)
    end
  end
  return opts
end

return M
