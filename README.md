# lazyflex.nvim

**lazyflex.nvim** is an add-on for [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.

The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

- Easier troubleshooting/testing from one central location.
  - Enable/disable multiple plugins by keyword.
  - Define and use presets for your own configuration.
  - Has presets for each default plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
  - Has options to skip loading the configuration modules (`options`, `autocmds`, `keymaps`) provided by **LazyVim**.
- Helps to verify the independence of the components in the configuration.
- When creating an issue, facilitates writing a concise reproducible configuration.
  - Contains [examples](#minimal-reproducible-configurations) for minimal configurations using **lazyflex**.

## Requirements

**References**:

- Requirements section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements)

## Installation

The plugin must be the first item in the spec!

```lua
require("lazy").setup({
  spec = {
    {
      "abeldekat/lazyflex.nvim",
      version = "*",
      cond = true, -- enable/disable lazyflex.nvim
      import = "lazyflex.hook",
      -- opts = {},
    },
    -- your plugins:
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
})
```

*Note*: The `cond` property in the snippet above is practical for quickly toggling
**lazyflex** on/off, whilst still keeping the plugin installed.
It is also possible to keep the plugin activated. **Lazyflex** is heavily optimized
and will opt-out very early when there are no keywords to process.

**References**:

- Installation section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-installation)
- `config.lazy`: [**LazyVim starter**](https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11)

## Important

When there are no keywords to enable/disable, **lazyflex** opts-out without modifying
any existing plugins.

When enabling, do not forget to add the name of the colorscheme to the keywords!

Alternatively:

1. Add the name to property [kw_always_enable](#configuration)
2. When using **LazyVim**: Use the `colorscheme` preset.
3. When using [custom presets](#adding-custom-presets): Create a `colorscheme` preset.

*Note*: It is not possible to configure multiple fragments of the plugin.

## Enabling/disabling in lazy.nvim

By default, **lazyflex** sets a `cond` property on each plugin managed by **lazy.nvim**.
The value of the property is either `true` or `false`, as configured in the `enable_match` setting.

The property needs to be set before **lazy.nvim** starts marking plugins enabled or disabled.
Therefore, **lazyflex** operates in the `spec phase`. See: `:Lazy profile`.
As part of the `spec phase`, **lazy.nvim** *requires* `"lazyflex.hook"`.

A similar approach can also be found in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

*Note*: It is also possible to attach to the `enabled` property instead, allowing plugins to be cleaned. (See [target_property](#configuration))

**References**:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

## Examples

### Using a personal configuration

The plugin can be used when your personal configuration is not build upon
a community setup like **LazyVim**.

Add to **lazyflex**:

> collection = false

```lua
  -- enable only harpoon, plenary and tokyonight:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      collection = false,
      kw = { "har", "plen", "tokyo" },
    },
  },

  -- disable only telescope and harpoon:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      collection = false,
      enable_match = false,
      kw = { "tele", "har" },
    },
  },
```

### Using a community setup like LazyVim

> Prerequisite: Add **LazyVim** to your plugin spec

*Note*: A preset setting that does not match a predefined preset will be ignored.

```lua
  -- Test a new plugin in isolation
  -- plugins: 44 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      kw = { "harpoon", "plenary", "tokyo" }, -- or "har" for the lazy...
    },
  },

  -- Only use telescope and the following modules: coding, colorscheme
  -- plugins: 30 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { presets = { "coding", "colorscheme" } },
      kw = { "tele", "plen" },
    },
  },

  -- Disable telescope and all plugins in the lsp module
  -- plugins: 8 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      enable_match = false,
      lazyvim = { presets = { "lsp" } },
      kw = { "tele" },
    },
  },

```

### Reusing specs from a collection of plugins

**LazyVim** can be used without loading its options, autocommands and keymappings.
The settings of the resulting configuration will default to stock Neovim.

This can be useful during testing or when reporting an issue for one of the plugins.
Instead of adding the full spec to a reproducible configuration,
the spec as defined in **LazyVim** collection can be used.

> Prerequisite: Add **LazyVim** to your plugin spec

Add to **lazyflex**:

> lazyvim = { config = { enabled = false } },

```lua
  -- LazyVim, only as a collection of plugins
  -- plugins: lazy.nvim, LazyVim, tokyonight
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { config = { enabled = false } },
      kw = { "tokyo" }, --> at least one keyword is needed!
    },
  },

  -- Using LazyVim's telescope spec and the colorscheme module
  -- plugins: lazy.nvim, LazyVim, tokyonight, catppuccin, telescope, plenary
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { config = { enabled = false }, presets = {"colorscheme"} },
      kw = { "tele", "plen" },
    },
  },

  -- Using all of LazyVim's specs except the UI
  -- plugins: 11 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      enable_match = false,
      lazyvim = { config = { enabled = false }, presets = { "ui" } },
    },
  },
```

### Adding custom presets

As an *optional* step, custom presets can be added to a `lua` module in the configuration of the user.
When absent, **lazyflex** uses [lazyflex.collections.stub](https://github.com/abeldekat/lazyflex.nvim/blob/main/lua/lazyflex/collections/stub.lua)
for the `user` collection.

The default name of the module **lazyflex** tries to `require` is `config.lazyflex`.
When present, the module should implement [lazyflex.collections.stub](https://github.com/abeldekat/lazyflex.nvim/blob/main/lua/lazyflex/collections/stub.lua).

User presets will only apply when properly implemented and are otherwise ignored.

Add to **lazyflex**:

> user = { presets = { "test" } },

The name of the module **lazyflex** expects can be changed:

> user = { mod = "config.anothername"}

```lua
  -- use your own presets:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      user = { presets = { "test" } },
    },
  },
```

Example implementation:

```lua
local M = {}

local presets = {
  test = { "harpoon" },
}

-- only act on plenary when enabling plugins
-- other plugins might crash when plenary is disabled
-- always enable the colorscheme
local when_enabling = {
  test = { "plenary", "tokyo" },
}

M.get_preset_keywords = function(name, enable_match)
  local result = presets[name]

  if result and enable_match then
    local extra = when_enabling[name]
    if extra then
      result = vim.list_extend(vim.list_extend({}, result), extra)
    end
  end
  return result or {}
end

M.return_spec = function(_) -- config
  return {}
end

return M
```

*Note*: It is possible to configure the `config` argument, passed into method `return_spec`.
The `user` collection contains `user.config` implicitly, having the same properties
as defined in `lazyvim.config`.
Those properties are all set to `false`, when the `user.config` section is not present in `opts`.

## Configuration

**lazyflex.nvim** comes with the following defaults:

```lua
{
  -- the "user" collection is always included:
  collection = { "lazyvim" }, -- set to false when not using a community setup

  -- lazyvim collection:
  lazyvim = {
    mod = "lazyflex.collections.lazyvim", -- do not modify
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

  -- user collection:
  user = {
    -- lazyflex will first try to require the default "mod" property
    -- The module is -optional- in the user's configuration,
    -- and should implement "lazyflex.collections.stub"
    mod = "config.lazyflex",
    fallback = "lazyflex.collections.stub", -- do not modify
    -- without user.mod, any user.presets specified will have no effect:
    presets = {}, -- example when implemented: { "test" }
  },

  -- the property of the plugin to set:
  target_property = "cond", -- or: "enabled"

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords for plugins to always enable:
  kw_always_enable = { "lazy" }, -- lazy.nvim, LazyVim, lazyflex

  -- keywords specified by the user:
  -- keywords from presets and kw_always_enable are merged in by lazyflex
  -- keywords specified by the user are appended to the final result
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline
}
```

## Minimal reproducible configurations

The plugin has two examples for writing reproducible configurations
using `lazyflex`, located in the `./repro` folder:

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
- [**LazyVim**](https://github.com/LazyVim/LazyVim): The concept of a plugin as a collection of other plugins.
