local M = {}

local defaults = {
  -- by default, load the config supplied by the plugin container:
  config = {
    enabled = true, -- quick switch, disabling the three options below:
    options = true, -- use config.options
    autocmds = true, -- use config.autocmds
    keymaps = true, -- use config.keymaps
  },

  -- for lazyvim, each module has a corresponding preset containing keywords
  plugin_container = "lazyvim", -- extension point for other plugin containers.
  presets_selected = {}, -- example: {"mini"}, only mini plugins

  -- presets defined in a module in your config.
  -- The module must provide a function: M.function = get_preset(name, enable_on_match)
  presets_personal_module = "config.presets",
  presets_personal = {}, -- example: {"test"}, when "test" provides keywords

  -- keywords for plugins to always enable:
  keywords_always_enable = { "lazy", "tokyo" },

  -- your own keywords will be merged with presets and always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins
  enable_on_match = true,
}

local apply_presets = function(selected_presets, presets_module, opts, apply_callback)
  for _, name in ipairs(selected_presets) do
    local ok, preset_keywords = pcall(presets_module.get_preset, name, opts)
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

  if use(opts.presets_selected) then
    local presets_module = require("lazyflex.presets").factory(opts.plugin_container)
    apply_presets(opts.presets_selected, presets_module, opts, apply_callback)
  end
  if use(opts.presets_personal) then
    local ok, presets_personal_module = pcall(require, opts.presets_personal_module)
    if ok then
      apply_presets(opts.presets_personal, presets_personal_module, opts, apply_callback)
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

  if not opts.config.enabled then
    opts.config.options = false
    opts.config.autocmds, opts.config.keymaps = false, false
  end

  return opts
end
return M
