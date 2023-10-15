local M = {}

local defaults = {
  -- lazyvim collection
  lazyvim = {
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

  -- user collection
  user = {
    get_preset_keywords = nil, -- a function, see chapter on custom presets
    return_spec = nil, -- a function, see chaper on custom presets
    mod = "config.lazyflex",

    presets = {}, -- example when implemented: { "test" }

    -- it's possible to implement custom loading of user settings in user.mod
    -- by default, load user's settings:
    config = {
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords matching plugins to always enable:
  kw_always_enable = {}, -- the "lazy" keyword is always included

  -- keywords specified by the user:
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline
}

local handlers = {
  lazyvim = function(_)
    local mod = require("lazyflex.collections.lazyvim")
    return {
      get_preset_keywords = mod.get_preset_keywords,
      return_spec = mod.return_spec,
    }
  end,
  user = function(collection)
    local mod = nil
    if not (collection.get_preset_keywords or collection.return_spec) then
      local ok, usermod = pcall(require, collection.mod)
      if ok then
        mod = usermod
      else
        mod = require("lazyflex.collections.stub")
      end
    end
    return {
      get_preset_keywords = collection.get_preset_keywords or mod and mod.get_preset_keywords,
      return_spec = collection.return_spec or mod and mod.return_spec,
    }
  end,
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
  return collection.config
end

local function sanitze_always_enable(kw_always_enable)
  local always_enable = kw_always_enable or {}
  if not vim.tbl_contains(always_enable, "lazy") then
    table.insert(always_enable, "lazy")
  end
  return always_enable
end

local function presets_to_kw(handler, presets, enable_match)
  local keywords = {}
  if vim.tbl_isempty(presets) then
    return keywords
  end

  for _, preset in ipairs(presets) do
    local words = handler.get_preset_keywords(preset, enable_match)
    keywords = vim.list_extend(keywords, words)
  end
  return keywords
end

local function transform(collection_names, opts_supplied)
  local actual = {}

  actual["enable_match"] = opts_supplied.enable_match
  actual["kw_always_enable"] = sanitze_always_enable(opts_supplied.kw_always_enable)
  actual["kw"] = {}

  for _, name in ipairs(collection_names) do
    local c = opts_supplied[name] -- the configuraton of the collection
    if c then
      local handler = handlers[name](c) -- the functions doing the actual work

      actual.kw = vim.list_extend(actual.kw, presets_to_kw(handler, c.presets, actual.enable_match))
      actual[name] = {
        return_spec = handler.return_spec,
        config = sanitize_config_options(c),
      }
    end
  end
  return actual
end

M.setup = function(opts_supplied, collection)
  -- merge
  local supplied = vim.tbl_deep_extend("force", defaults, opts_supplied or {})

  -- sanitze input and resolve presets into keywords
  local opts = transform(collection, supplied)

  -- add keywords supplied by user
  local user_keywords = supplied.kw and vim.tbl_map(string.lower, supplied.kw) or {}
  opts.kw = vim.list_extend(opts.kw, user_keywords) -- keywords including presets

  -- when there are kw, also add kw_always_enable  when enable_match==true
  if not vim.tbl_isempty(opts.kw) then
    if opts.enable_match then
      opts.kw = vim.list_extend(vim.list_extend({}, opts.kw_always_enable), opts.kw)
    end
  end
  return opts
end

return M
