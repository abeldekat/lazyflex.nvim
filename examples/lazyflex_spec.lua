--[[
An example spec for lazyflex
NOTE: Using these settings, lazyflex returns early:
  - filter_modules.enabled = false
  - there are no keywords to process
--]]

local M = {}
M.lazyflex = {
  "abeldekat/lazyflex.nvim",
  version = "*",
  cond = true,
  import = "lazyflex.hook",
  opts = function()
    local no_op = false
    if no_op then
      return nil -- no opts supplied -> lazyflex returns immediately
    end

    -- NOTE: Change to the real location:
    local collection = require("examples.flex_collection")

    local settings = { enabled = true }
    local presets = {}
    return {
      filter_modules = { enabled = false, kw = {} },
      lazyvim = { settings = settings, presets = presets },
      user = {
        change_settings = collection.change_settings,
        settings = settings,
        get_preset_keywords = collection.get_preset_keywords,
        presets = presets,
      },
      kw_always_enable = { "tokyo" },
      enable_match = true,
      kw = {},
      override_kw = {},
    }
  end,
}
return M
