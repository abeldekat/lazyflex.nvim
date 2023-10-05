# lazyflex.nvim

**lazyflex.nvim** is an add-on for [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.

The plugin facilitates troubleshooting and writing reproducible configurations.

## Features

- Easier troubleshooting/testing from one central location.
- Enable/disable multiple plugins by keyword.
- Define and use presets for your own configuration
- Has presets for each plugin module in [**LazyVim**](https://github.com/LazyVim/LazyVim).
- Has options to skip loading the configuration modules provided by **LazyVim**.
- When creating an issue, facilitates writing a concise reproducible configuration.

## Requirements

**References**:

- Requirements section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements)

## Installation

The plugin must be the first item in the spec!

```lua
local cond_flex = true -- enable lazyflex.nvim
local import_flex = cond_flex and "lazyflex.plugins.intercept" or "lazyflex.plugins.noop"
require("lazy").setup({
  spec = {
    {
      "abeldekat/lazyflex.nvim",
      cond = cond_flex,
      import = import_flex,
      -- opts = {},
    },
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
})
```

**References**:

- Installation section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-installation)
- `config.lazy.lua`: [**LazyVim starter**](https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11)

## Important

When there are no keywords to enable/disable, **lazyflex** opts-out without modifying
any existing plugins.

When enabling, do not forget to add the name of the colorscheme to the keywords!

Or, alternatively:

1. Add the name to property `keywords_to_always_enable`.
2. When using custom presets: Add the name to the logic in the corresponding module.

_Note_: It is not possible to configure multiple fragments of the plugin.

## Enabling/disabling in lazy.nvim

By default, **lazyflex** sets a `cond` property on each plugin managed by **lazy.nvim**.
The value of the property is either `true` or `false`, as configured in the `enable_on_match` setting.

The property needs to be set before **lazy.nvim** starts marking plugins enabled or disabled.
Therefore, **lazyflex** operates in the `spec phase`. See: `:Lazy profile`.
As part of the `spec phase`, **lazy.nvim** _requires_ `"lazyflex.plugins.intercept"`.

A similar approach can also be found in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

_Note_: It is also possible to attach to the `enabled` property instead, allowing plugins to be cleaned.

**References**:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration, `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

## Examples

### Using a community setup like LazyVim

> Prerequisite: Add **LazyVim** to your plugin spec

_Note_: A preset setting that does not match a predefined preset will be ignored.

```lua
  -- Test a new plugin in isolation
  -- plugins: 44 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      keywords = { "harpoon", "plenary", "tokyo" }, -- or "har" for the lazy...
    },
  },

  -- Only use the coding module and telescope
  -- plugins: 31 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      lazyvim = { presets = { "coding" } },
      keywords = { "tele", "plen", "tokyo" },
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

### Borrowing from LazyVim's collection of plugins

**LazyVim** can be used without loading its options, autocommands and keymappings.
The settings of the resulting configuration will default to stock neovim.

This can be useful during testing or when reporting an issue for one of the plugins.
Instead of adding the full spec to a reproducible configuration,
the spec as defined in **LazyVim** can be used.

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
      keywords = { "tokyo" }, --> at least one keyword is needed!
    },
  },

  -- Using LazyVim's telescope spec
  -- plugins: lazy.nvim, LazyVim, tokyonight, telescope, plenary
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      lazyvim = { config = { enabled = false } },
      keywords = { "tele", "plen", "tokyo" },
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

### Without using a community setup

The plugin can also be used when your personal configuration is not build upon
a community setup like **LazyVim**.

Add to **lazyflex**:

> collection = false

```lua
  -- enable only harpoon, plenary and tokyonight:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      collection = false,
      keywords = { "har", "plen", "tokyo" },
    },
  },

  -- disable only telescope and harpoon:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      collection = false,
      enable_on_match = false,
      keywords = { "tele", "har" },
    },
  },
```

### Adding custom presets

Custom presets can be added to a `lua` module in the configuration of the user.
This is an optional step.
When the module is not present, **lazyflex** uses `lazyflex.collections.stub`.

The default name **lazyflex** expects is `config.lazyflex`.
The module should implement [`lazyflex.collections.stub`](https://github.com/abeldekat/lazyflex.nvim/blob/main/lua/lazyflex/collections/stub.lua).
User presets will only apply when properly implemented and are otherwise ignored.

Add to **lazyflex**:

> user = { presets = { "test" } },

The name of the module **lazyflex** expects can be changed:

> user = { mod = "config.anothername"}

```lua
  -- use your own presets:
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.plugins.intercept",
    opts = {
      user = { presets = { "test" } },
    },
  },
```

Example implementation, added to `config.lazyflex`:

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

M.get_preset_keywords = function(name, enable_on_match)
  local result = presets[name]

  if result and enable_on_match then
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

_Note_: It is possible to configure the `config` argument, passed into method `return_spec`.
The `user` collection contains `user.config` implicitly, having the same properties
as defined in `lazyvim.config`.
Those properties are all set to `false`, when the `user.config` section is not present in `opts`.

## Configuration

**lazyflex.nvim** comes with the following defaults:

<!-- config:start -->

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
    -- without user.mod, any user.presets specified will have no effect:
    fallback = "lazyflex.collections.stub", -- do not modify
    presets = {}, -- example when implemented: { "test" }
  },

  -- keywords for plugins to always enable:
  keywords_to_always_enable = { "lazy" },

  -- keywords specified by the user
  -- Merged with the keywords from the presets and keywords_to_always_enable:
  keywords = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- either enable or disable matching plugins:
  enable_on_match = true,
  -- the property of the plugin to set:
  target_property = "cond", -- or: "enabled"
}
```

<!-- config:end -->

## Templates for "repro"

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
