local M = {}

local defaults = {
  -- by default, load lazyvim's config:
  config = {
    enabled = true,
    options = true, -- use config.options
    autocmds = true, -- use config.autocmds
    keymaps = true, -- use config.keymaps
  },

  -- TODO: could be extended to use other collections, astronvim v4 for example
  --
  -- when specified, prepend the keywords with the keywords the preset provides
  -- each lazyvim module has a corresponding preset containing keywords
  presets_collection = "lazyvim",
  presets_selected = {},

  -- presets defined in a module in your config.
  -- The module must provide a function: M.function = get(name, enable_on_match)
  presets_personal_module = "config.presets",
  presets_personal = {},

  -- keywords are prepended with plugins to always enable:
  keywords_always_enable = { "lazy", "tokyo" },

  -- your own keywords will be merged with presets and always_enable
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins
  enable_on_match = true,
}

local apply_presets = function(presets, presets_module, enable_on_match, apply_preset)
  for _, selected in ipairs(presets) do
    local ok, preset_keywords = pcall(presets_module.get, selected, enable_on_match)
    if ok then
      apply_preset(preset_keywords)
    end
  end
end

-- if opts.presets_to_use and not vim.tbl_isempty(opts.presets_to_use) then
--   local presets = require("lazyflex.presets").from_collection(opts.presets_collection)
--   for _, preset in ipairs(opts.presets_to_use) do
--     local preset_keywords = presets.get(preset, opts.enable_on_match)
--     keywords = vim.list_extend(preset_keywords, keywords)
--   end
-- end
local extend_keywords = function(opts)
  local keywords = opts.keywords and vim.tbl_map(string.lower, opts.keywords) or {}

  local function apply_preset(preset_keywords)
    keywords = vim.list_extend(preset_keywords, keywords)
  end
  local function use(selected_presets)
    return selected_presets and not vim.tbl_isempty(selected_presets)
  end

  if use(opts.presets_selected) then
    local presets_module = require("lazyflex.presets").from_collection(opts.presets_collection)
    apply_presets(opts.presets_selected, presets_module, opts.enable_on_match, apply_preset)
  end
  if use(opts.presets_personal) then
    local ok, presets_personal_module = pcall(require, opts.presets_personal_module)
    if ok then
      apply_presets(opts.presets_personal, presets_personal_module, opts.enable_on_match, apply_preset)
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
