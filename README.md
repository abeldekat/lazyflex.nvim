# 💤 lazyflex.nvim

WIP

**lazyflex.nvim** hooks into [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.
The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

1. Enable/disable multiple plugins by keyword from one central location.
2. Define and use presets for your own configuration, optionally using a plugin container like **LazyVim**.
3. Has presets for each plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
4. Has options to skip loading the configuration modules **LazyVim** provides.
5. Easier troubleshooting without modifying any configuration.
6. When creating an issue, facilitates writing a concise reproducible configuration.

## Requirements

References:

- Requirements section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements)

## Installation

References:

- Installation section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-installation)
- `config.lazy.lua`: [**LazyVim starter**](https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11)

The plugin must be the first item in the spec!

```lua
local use_flex = false -- true activates the plugin
local plugin_flex = not use_flex and {}
  or {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {}, -- defaults to: LazyVim, lazy.nvim, and tokyonight
  }
require("lazy").setup({
  spec = {
    plugin_flex,
    -- your plugins:
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
})
```

## Using lazy's conditional keyword

References:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

**lazyflex** attaches a `cond` property to each spec in the list of specs managed by **lazy.nvim**.
The value of the property is either `true` or `false`, depending on `config.enable_on_match`.

## Examples

```lua
-- WIP
```

## Configuration

**lazyflex.nvim** comes with the following defaults:

```lua
{
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

  -- your own keywords will be merged with presets and keywords_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins
  enable_on_match = true,
}
```

## Ideas

Not in scope for now, but possible:

- add presets for AstroNvim-v4
- Combine specs from multiple plugin containers: LazyVim, AstroNvim-v4
