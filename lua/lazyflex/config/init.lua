local M = {}

-- for each item in collection: The corresponding lua module
local mods = {}

local defaults = {
  -- the "user" collection is always included:
  collection = { "lazyvim" }, -- set to false when not using any community plugin

  -- lazyvim collection:
  lazyvim = {
    mod = "lazyflex.collections.lazyvim",
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    -- by default, load the settings supplied:
    config = {
      enabled = true, -- quick switch, disabling the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user collection:
  user = {
    -- collection defined in a module in your config.
    -- The module must implement the stub:
    mod = "lazyflex.collections.stub", -- implement for example: "config.lazyflex"
    presets = {}, -- example: {"test"}, where "test" provides keywords
  },

  -- keywords for plugins to always enable:
  keywords_to_always_enable = { "lazy", "tokyo" },

  -- keywords specified by the user
  -- Merged with the keywords from the presets and keywords_to_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins:
  enable_on_match = true,
  -- the property of the plugin to set:
  target_property = "cond", -- or: "enable"
}

local function sanitize(opts)
  local collection = opts.collection or {}

  if not vim.tbl_contains(collection, "user") then
    table.insert(collection, "user")
  end

  return vim.tbl_filter(function(name)
    local result = false
    local col = opts[name]

    if col then
      if not col.config then
        col.config = { enabled = false }
      end
      if not col.config.enabled then
        col.config.options = false
        col.config.autocmds = false
        col.config.keymaps = false
      end
      mods[name] = require(col.mod)
      result = true -- collection and matching module: add to the list
    end

    return result -- do not add to the list
  end, collection)
end

local function from_presets(name, opts)
  local col = opts[name]
  local mod = mods[name]
  if not col.presets or vim.tbl_isempty(col.presets) then
    return {}
  end

  local keywords = {}
  for _, preset in ipairs(col.presets) do
    local words = mod.get_preset_keywords(preset, opts.enable_on_match)
    keywords = vim.list_extend(keywords, words)
  end
  return keywords
end

M.setup = function()
  local Config = require("lazy.core.config")
  local Plugin = require("lazy.core.plugin")
  local opts = Plugin.values(Config.spec.plugins["lazyflex.nvim"], "opts", false)

  -- merge
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  -- each name in "collection" should match a corresponding key in opts
  -- the mod property of a collection must be requireable
  opts.collection = sanitize(opts)

  -- keywords
  local keywords = {}
  if opts.enable_on_match then
    keywords = vim.list_extend(keywords, opts.keywords_to_always_enable)
  end
  for _, name in ipairs(opts.collection) do
    keywords = vim.list_extend(keywords, from_presets(name, opts))
  end
  local user_keywords = opts.keywords and vim.tbl_map(string.lower, opts.keywords) or {}
  opts.keywords = vim.list_extend(keywords, user_keywords)

  return opts
end

M.for_each_collection = function(opts, callback)
  for _, name in ipairs(opts.collection) do
    callback(mods[name], opts[name].config)
  end
end

return M
