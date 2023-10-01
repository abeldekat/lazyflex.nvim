# 💤 lazyflex.nvim

WIP

**lazyflex.nvim** hooks into [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.
The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

- Enable/disable multiple plugins by keyword from one central location.
- Define and use presets for your own configuration, optionally using a plugin container like **LazyVim**.
- Has presets for each plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
- Has options to skip loading the configuration modules **LazyVim** provides.
- Easier troubleshooting without modifying any configuration.
- When creating an issue, facilitates writing a concise reproducible configuration.

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

## Using lazy's conditional enabling

References:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration, `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

**lazyflex** attaches a `cond` property to each plugin in the list of plugins managed by **lazy.nvim**.
The value of the property is either `true` or `false`, depending on `enable_on_match`.

The `cond` property needs to be attached before **lazy.nvim** starts marking plugins enabled or disabled.
For now, this can only be done in the `spec phase`, see `:Lazy profile`.

The approach is also used in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

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

- Add presets for AstroNvim-v4
- Combine specs from multiple plugin containers: LazyVim, AstroNvim-v4

## History

- Debug nvim crash with plugins: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1322#discussioncomment-6728171)
- Turning LazyVim into Kickstart: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1483)
- Adding to repro.lua: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1493)
- Feature: integrated binary debugging: [**lazy.nvim**](https://github.com/folke/lazy.nvim/issues/1047#issuecomment-1735131704)

## Credits

@dpetka2001, for his feedback during my early attempts
@folke, for creating **lazy.nvim** and **LazyVim**(to name a few...)

This plugin can be considered a tribute to:

- **lazy.nvim**: its architecture and possibilities.
- **LazyVim**: its concept of a plugin as a thin container for other plugins.
