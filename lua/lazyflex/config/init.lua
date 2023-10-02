local M = {}

local defaults = {

  -- any setup like LazyVim, containing both configuration and specs:
  container = { -- see lazyflex.containers.lazyvim
    enabled = true,
    name = "LazyVim", -- for lazyvim, a preset exists for each module containing keywords
    presets = {}, -- example: {"coding"}: matches plugins from the coding module

    -- by default, load the config supplied by the plugin container:
    config = {
      enabled = true, -- quick switch, disabling the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user config:
  user = {
    -- presets defined in a module in your config:
    -- The module must have: M.function = get_preset_keywords(name, enable_on_match)
    module = "config.presets",
    presets = {}, -- example: {"test"}, where "test" provides keywords
  },

  -- keywords for plugins to always enable:
  keywords_always_enable = { "lazy", "tokyo" },
  -- keywords specified by the user are merged with the keywords found in presets
  -- and the keywords in keywords_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins
  enable_on_match = true,
  -- the plugin property to set
  target_property = "cond", -- or: "enable"
}

local apply_presets = function(selected_presets, presets_module, opts, apply_callback)
  for _, name in ipairs(selected_presets) do
    local ok, preset_keywords = pcall(presets_module.get_preset_keywords, name, opts)
    if ok then
      apply_callback(preset_keywords)
    end
  end
end

local extend_keywords = function(opts)
  local keywords = opts.keywords and vim.tbl_map(string.lower, opts.keywords) or {}

  local function apply_callback(preset_keywords)
    keywords = vim.list_extend(preset_keywords, keywords)
  end
  local function use(selected_presets)
    return selected_presets and not vim.tbl_isempty(selected_presets)
  end

  if opts.container and opts.container.enabled then
    if use(opts.container.presets) then
      local preset_module = require("lazyflex.containers").factory(opts)
      apply_presets(opts.container.presets, preset_module, opts, apply_callback)
    end
  end
  if opts.user then
    if use(opts.user.presets) then
      local ok, preset_module = pcall(require, opts.user.module)
      if ok then
        apply_presets(opts.user.presets, preset_module, opts, apply_callback)
      end
    end
  end

  if opts.enable_on_match then
    keywords = vim.list_extend(opts.keywords_always_enable, keywords)
  end
  return keywords
end

M.setup = function()
  local Config = require("lazy.core.config")
  local Plugin = require("lazy.core.plugin")
  local opts = Plugin.values(Config.spec.plugins["lazyflex.nvim"], "opts", false)

  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  opts.keywords = extend_keywords(opts)

  if opts.container and opts.container.config then
    local container_conf = opts.container.config
    if not container_conf.enabled then
      container_conf.options = false
      container_conf.autocmds, container_conf.keymaps = false, false
    end
  end
  return opts
end
return M
