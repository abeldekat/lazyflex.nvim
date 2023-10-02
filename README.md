# lazyflex.nvim

**lazyflex.nvim** hooks into [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.

The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

- Easier troubleshooting/testing without modifying your configuration.
- When creating an issue, facilitates writing a concise reproducible configuration.
- Enable/disable multiple plugins by keyword from one central location.
- Define and use presets for your own configuration, optionally using a plugin container like **LazyVim**.
- Has presets for each plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
- Has options to skip loading the configuration modules provided by **LazyVim**.

## Requirements

References:

- Requirements section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements)

## Installation

The plugin must be the first item in the spec!

It is not possible to configure multiple fragments of the plugin.

The hooks are applied immediately when **lazy.nvim** requires `"lazyflex.plugins.intercept"`

```lua
local use_flex = false -- true activates the plugin
local plugin_flex = not use_flex and {}
  or {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      -- 3 plugins by default: "LazyVim", "lazy.nvim", and "tokyonight"
    },
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

References:

- Installation section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-installation)
- `config.lazy.lua`: [**LazyVim starter**](https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11)

## Using lazy's conditional enabling

**lazyflex** attaches a `cond` property to each plugin in the list of plugins managed by **lazy.nvim**.
The value of the property is either `true` or `false`, depending on `enable_on_match`.

The `cond` property needs to be attached before **lazy.nvim** starts marking plugins enabled or disabled.
For now, this can only be done in the `spec phase`, see `:Lazy profile`.

The approach is also used in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

References:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration, `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

## Examples

```lua
-- lazy.nvim: LazyVim can be used as plugin provider
-- plugins: lazy.nvim, LazyVim, tokyonight
{
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    config = { enabled = false },
  },
}

-- lazy.nvim: Using LazyVim's telescope and plenary specs
-- plugins: lazy.nvim, LazyVim, tokyonight, telescope, plenary
{
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    config = { enabled = false },
    keywords = { "tele", "plen" },
  },
}

-- lazy.nvim: Using all LazyVim's specs except the UI
-- plugins: 11 disabled
{
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    config = { enabled = false },
    enable_on_match = false,
    presets_selected = {"ui"},
  },
}

-- LazyVim: only use the coding module, and telescope and plenary
-- plugins: 31 disabled
{
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    presets_selected = {"coding"},
    keywords = { "tele", "plen" },
  },
}

-- LazyVim: disable plugins from the lsp module, and telescope and plenary
-- plugins: 9 disabled
{
  "abeldekat/lazyflex.nvim",
  import = "lazyflex.plugins.intercept",
  opts = {
    enable_on_match = false,
    presets_selected = {"lsp"},
    keywords = { "tele", "plen" },
  },
}
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
  presets_selected = {}, -- example: {"coding"}: only with plugins from the coding module

  -- presets defined in a module in your config.
  -- The module must provide a function: M.function = get_preset_keywords(name, enable_on_match)
  presets_personal_module = "config.presets",
  presets_personal = {}, -- example: {"test"}, where "test" provides keywords

  -- keywords for plugins to always enable:
  keywords_always_enable = { "lazy", "tokyo" },

  -- your own keywords will be merged with presets and keywords_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins
  enable_on_match = true,
}
```

## History

The idea grew over time:

- Debug nvim crash with plugins: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1322#discussioncomment-6728171)
- Turning LazyVim into Kickstart: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1483)
- Adding to repro.lua: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1493)
- Feature: integrated binary debugging: [**lazy.nvim**](https://github.com/folke/lazy.nvim/issues/1047#issuecomment-1735131704)

## Acknowledgements

- [**lazy.nvim**](https://github.com/folke/lazy.nvim): The architecture, semantics and enhanced possibilities.
- [**LazyVim**](https://github.com/LazyVim/LazyVim): The concept of a plugin as a thin container for other plugins.
