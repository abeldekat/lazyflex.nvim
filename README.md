# lazyflex.nvim

**lazyflex.nvim** hooks into [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.

The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

- Easier troubleshooting/testing from one central location.
- Enable/disable multiple plugins by keyword.
- Define and use presets for your own configuration
- Has presets for each plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
- Has options to skip loading the configuration modules provided by **LazyVim**.
- When creating an issue, facilitates writing a concise reproducible configuration.

## Requirements

References:

- Requirements section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements)

## Installation

The plugin must be the first item in the spec!

The hooks are applied immediately when **lazy.nvim** _requires_ `"lazyflex.plugins.intercept"`.

Thus, it is not possible to configure multiple fragments of the plugin.

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

By default, **lazyflex** attaches a `cond` property to each plugin managed by **lazy.nvim**.
The value of the property is either `true` or `false`, depending on the `enable_on_match` setting.
It is also possible to attach the `enable` property instead, allowing plugins to be cleaned.

The property needs to be attached before **lazy.nvim** starts marking plugins enabled or disabled.
This can only be done in the `spec phase`. See: `:Lazy profile`.

A similar approach can also be found in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

References:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration, `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

## Examples

### Using a community plugin like LazyVim

> Prerequisite: Add **LazyVim** to your plugin spec

```lua
  -- Test a new plugin in isolation
  -- plugins: 44 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      keywords = { "harpoon", "plenary" }, -- or "har" for the lazy...
    },
  },

  -- Only use the coding module, and telescope and plenary
  -- plugins: 31 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      lazyvim = { presets = { "coding" } },
      keywords = { "tele", "plen" },
    },
  },

  -- Disable telescope and all plugins in the lsp module
  -- plugins: 8 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      enable_on_match = false,
      lazyvim = { presets = { "lsp" } },
      keywords = { "tele" },
    },
  },

```

### LazyVim as a collection of plugins

**LazyVim** can be used without loading its options, autocommands and keymappings.
The settings of the resulting configuration will default to stock neovim.

This can be useful during testing or when reporting an issue for one of the plugins.
Instead of adding the full spec to a reproducible configuration, LazyVim's spec
can be used.

> Prerequisite: Add **LazyVim** to your plugin spec

Add to **lazyflex**:

> lazyvim = { config = { enabled = false } },

```lua
  -- LazyVim, only as a collection of plugins
  -- plugins: lazy.nvim, LazyVim, tokyonight
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      lazyvim = { config = { enabled = false } },
    },
  },

  -- Using LazyVim's telescope and plenary specs
  -- plugins: lazy.nvim, LazyVim, tokyonight, telescope, plenary
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      lazyvim = { config = { enabled = false } },
      keywords = { "tele", "plen" },
    },
  },

  -- Using all of LazyVim's specs except the UI
  -- plugins: 11 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      enable_on_match = false,
      lazyvim = { config = { enabled = false }, presets = { "ui" } },
    },
  },
```

### Personal configuration only

```lua
print("todo")
```

## Configuration

**lazyflex.nvim** comes with the following defaults:

<!-- config:start -->

```lua
{
  -- the "user" collection is always included:
  collection = { "lazyvim" }, -- set to false when not using any community plugin

  -- lazyvim collection:
  lazyvim = {
    mod = "lazyflex.collections.lazyvim",
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    -- by default, load the settings supplied:
    config = {
      enabled = true, -- quick switch, disabling the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user collection:
  user = {
    -- collection defined in a module in your config.
    -- The module must implement the stub:
    mod = "lazyflex.collections.stub", -- implement for example: "config.lazyflex"
    presets = {}, -- example: {"test"}, where "test" provides keywords
  },

  -- keywords for plugins to always enable:
  keywords_to_always_enable = { "lazy", "tokyo" },

  -- keywords specified by the user
  -- Merged with the keywords from the presets and keywords_to_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins:
  enable_on_match = true,
  -- the property of the plugin to set:
  target_property = "cond", -- or: "enable"
}
```

<!-- config:end -->

## Templates for "repro"

The plugin has two examples for writing reproducible configurations
using `lazyflex` in the `./repro` folder:

- [`repro_lazy.lua`](https://github.com/abeldekat/lazyflex.nvim/blob/main/repro/repro_lazy.lua)
- [`repro_lazyvim.lua`](https://github.com/abeldekat/lazyflex.nvim/blob/main/repro/repro_lazyvim.lua)

## History

The idea grew over time:

- Debug nvim crash with plugins: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1322#discussioncomment-6728171)
- Turning LazyVim into Kickstart: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1483)
- Adding to repro.lua: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1493)
- Feature: integrated binary debugging: [**lazy.nvim**](https://github.com/folke/lazy.nvim/issues/1047#issuecomment-1735131704)

## Acknowledgements

- [**lazy.nvim**](https://github.com/folke/lazy.nvim): The architecture, semantics and enhanced possibilities.
- [**LazyVim**](https://github.com/LazyVim/LazyVim): The concept of a plugin as a container for other plugins.
