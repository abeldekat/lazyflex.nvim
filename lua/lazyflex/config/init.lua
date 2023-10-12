local M = {}

-- for each valid item in collection: The corresponding lua module
local mods = {}

local defaults = {
  -- the "user" collection is always included:
  collection = { "lazyvim" }, -- set to false when not using a community setup

  -- lazyvim collection:
  lazyvim = {
    mod = "lazyflex.collections.lazyvim", -- do not modify
    -- any lazyvim.presets specified that don't match have no effect:
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    -- by default, load lazyvim's settings:
    config = {
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user collection:
  user = {
    -- lazyflex will first try to require the default "mod" property
    -- The module is -optional- in the user's configuration,
    -- and should implement "lazyflex.collections.stub"
    mod = "config.lazyflex",
    fallback = "lazyflex.collections.stub", -- do not modify
    -- without user.mod, any user.presets specified will have no effect:
    presets = {}, -- example when implemented: { "test" }
  },

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords for plugins to always enable:
  kw_always_enable = { "lazy" }, -- matching lazy.nvim, LazyVim, lazyflex

  -- keywords specified by the user:
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline
}

local function sanitize_config_options(collection)
  if not collection.config then
    collection.config = { enabled = false }
  end
  if not collection.config.enabled then
    collection.config.options = false
    collection.config.autocmds = false
    collection.config.keymaps = false
  end
end

local function sanitize(opts)
  local collection = opts.collection or {}
  if not vim.tbl_contains(collection, "user") then
    table.insert(collection, "user")
  end

  -- opts.collection is a table of names
  -- each name is a table key referring to a corresponding table in opts
  -- each table representing the collection has a mod property that will be "required".
  return vim.tbl_filter(function(name)
    local result = false -- by default: only add when name is valid

    local col = opts[name] -- the named collection
    if col then
      local ok, usermod = pcall(require, col.mod)
      if not ok and col.fallback then
        usermod = require(col.fallback)
      end
      if usermod then
        sanitize_config_options(col)
        mods[name] = usermod
        result = true -- collection and matching module: add to the list
      end
    end

    return result
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
    local words = mod.get_preset_keywords(preset, opts.enable_match)
    keywords = vim.list_extend(keywords, words)
  end
  return keywords
end

M.setup = function(opts)
  -- merge
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  -- sanitize
  opts.collection = sanitize(opts)

  -- calculate keywords
  local keywords = {}
  for _, name in ipairs(opts.collection) do
    keywords = vim.list_extend(keywords, from_presets(name, opts))
  end
  local user_keywords = opts.kw and vim.tbl_map(string.lower, opts.kw) or {}
  opts.kw = vim.list_extend(keywords, user_keywords) -- the result

  return opts
end

M.for_each_collection = function(opts, callback)
  for _, name in ipairs(opts.collection) do
    callback(mods[name], opts[name].config)
  end
end

return M
