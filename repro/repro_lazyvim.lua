-- Minimal `init.lua` to reproduce an issue. Save as `repro.lua` and run with `nvim -u repro.lua`

-- sets std paths to use .repro and bootstraps lazy
local function bootstrap(root) -- DO NOT change the paths
  for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
  end
  local lazypath = root .. "/plugins/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
  end
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
end
local root = vim.fn.fnamemodify("./.repro", ":p")
bootstrap(root)

-- optional: enable lazyflex.nvim
local use_flex = false
local plugin_flex = not use_flex and {}
  or { -- specify at least one option to activate lazyflex
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    -- opts = {},
  }

-- install plugins
local plugins = {
  plugin_flex,
  "folke/tokyonight.nvim",
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  -- add any other plugins here
}
require("lazy").setup(plugins, {
  root = root .. "/plugins",
})
-- add anything else here
