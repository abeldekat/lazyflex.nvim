# lazyflex.nvim

**lazyflex.nvim** is an add-on for [lazy.nvim], a modern plugin manager for Neovim.

Its main objective is to make it easier to test and troubleshoot a `Neovim` configuration.

## Demo

<https://github.com/abeldekat/lazyflex.nvim/assets/58370433/1bb1ba01-b6a3-4753-b3d7-e05bc1cd1ce7>

> The code used in the demo can be found [here](https://github.com/abeldekat/starter/blob/lazyflex_demo/lua/config/lazyflex_test.lua)

## Features

- Easier troubleshooting/testing from one central location.
  - Enable/disable multiple plugins by keyword.
  - Define and use [presets] for your own configuration.
  - Has presets for each default plugin module in [LazyVim].
  - Has options to skip loading the configuration modules
  (`options`, `autocmds`, `keymaps`) provided by [LazyVim]
- Helps to verify the independence of the components in the configuration.
- When creating an issue, facilitates writing a concise reproducible configuration.
  - Contains [examples] for minimal configurations using **lazyflex**.

## Requirements

**References**:

- [lazy.nvim requirements]

## Installation

The plugin must be the first item in the spec!

```lua
require("lazy").setup({
  spec = {
    {
      "abeldekat/lazyflex.nvim",
      version = "*",
      cond = true,
      import = "lazyflex.hook",
      opts = {},
    },
    -- your plugins:
    -- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- { import = "plugins" },
  },
})
```

_Note_: The `cond` property in the snippet above is practical for quickly toggling
**lazyflex** on or off, whilst still keeping the plugin installed.
**Lazyflex** is heavily optimized, and can also be kept enabled.

_Note_: It is not possible to configure multiple fragments of the plugin.

_Note_: See [examples/lazyflex_spec.lua] for a more complete **lazyflex** spec.

**References**:

- [lazy.nvim installation]
- [LazyVim starter]

## Concepts

**lazyflex**:

1. Returns immediately when there are no keywords or presets supplied
to _enable_ or _disable_
2. Only operates on plugins
that are not unconditionally disabled(`plugin.enabled = false`)

### Important properties

- `filter_modules.kw`: when enabled, only import a selection
of the _modules_ in use, thereby reducing the number of plugins to consider.
See lazy.nvim's [import]
- `kw`: a list of words matching names of plugins.
- `preset`: a _predefined_ list of words matching names of plugins
- `enable_match`:
  - `true`(_enable_ incrementally, default):
  _enable_ all plugins that match keywords, _disable_ the others.
  - `false`(_disable_ incrementally):
  _disable_ all plugins that match keywords, _enable_ the others
- `override_kw`: invert `enable_match` on a plugin when its name has a match
in both this list of words **and** in `kw` including `presets`

When using presets: References to a non-existing preset will be ignored.

## Colorscheme

_Important_: The name of the colorscheme must be in the keywords
when `enable_match = true`

Approach:

1. Add the name to property `kw` in the [opts]: `kw = { "toky" }`
2. Add the name to property `kw_always_enable` in the [opts]:
`kw_always_enable = { "toky" }`
3. When using [LazyVim]: Use the `colorscheme` preset.
4. When using custom [presets]: Create a `colorscheme` preset.

## Use cases

### Using a personal configuration

The plugin can be used when the user's configuration is not build upon
a community setup like [LazyVim]. Personal [presets] can be configured.

### Using a community setup like LazyVim

> Prerequisite: Add the [LazyVim] plugin

### Reusing specs from a collection of plugins

[LazyVim] can be used without loading its options, autocommands or keymappings.
The settings of the resulting configuration will default to stock `Neovim`.

Scenario's where this can be useful:

- during testing
- when reporting an issue for one of the plugins,
reusing [LazyVim]'s definitions in a [reproducible configuration].

> Prerequisite: Add the [LazyVim] plugin

Add to [opts]:

> `lazyvim = { settings = { enabled = false } }`

## Examples

```lua
  -- Enable harpoon, plenary and tokyonight. Disable all other plugins.
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = { kw = { "har", "plen", "tokyo" } },
  },

  -- Disable telescope and harpoon. Enable: all other plugins.
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = { enable_match = false, kw = { "tele", "har" } },
  },

  -- Only use lazy.nvim, LazyVim, and tokyonight, without LazyVim's settings.
  -- An alternative would be a lazy.nvim spec, addding tokyonight.
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { settings = { enabled = false } },
      kw = { "tokyo" },
    },
  },

  -- All specs except the ones defined in LazyVim's ui module
  -- Plugins: approximately 10 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { presets = { "ui" } },
      enable_match = false,
    },
  },

  -- Enable plugins in LazyVim's editor module and plugins matching `cmp`,
  -- except nvim-spectre(editor), flash.nvim(editor) and cmp_luasnip
  -- Plugins: approximately 30 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      lazyvim = { presets = { "editor" } },
      kw = { "tokyo", "cmp" },
      override_kw = { "spectre", "fla", "luasn" },
    },
  },

  -- Enable all plugins, excluding plugins from other modules than
  -- either "lazyvim.plugins" or "plugins"
  -- To do this manually, one would need to comment out all "other" imports...
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      filter_modules = { enabled = true },
      enable_match = false,
    },
  },

  -- Enable the minimal amount of plugins needed for running neotest-python
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.hook",
    opts = {
      filter_modules = { enabled = true, kw = { "py", "test" } },
      lazyvim = { presets = { "treesitter"} }
      kw = { "toky", "test", "plen" },
    },
  },
```

## Configuration

**lazyflex.nvim** comes with the following defaults:

```lua
{
  -- when enabled: only import a selection of the modules in use
  filter_modules = {
    enabled = false,
    kw = {}, -- contains keywords for module names to import
    always_import = {}, -- always contains "lazyvim.plugins" and "plugins"
  },

  -- lazyvim settings
  lazyvim = {
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    settings = { -- load lazyvim's settings by default:
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user settings
  user = {
    -- lazyflex.collections.stub is used by default as a pass-through

    -- optional: functions overriding lazyflex.collections.stub
    get_preset_keywords = nil,
    change_settings = nil,

    presets = {}, -- example, when implemented: { "editor" }

    settings = { -- passed into function change_settings:
      enabled = true, -- quick switch. Disables the three options below:
      options = true,
      autocmds = true,
      keymaps = true,
    },
  },

  -- either enable or disable matching plugins:
  enable_match = true,

  -- keywords matching plugins to always enable:
  kw_always_enable = {}, -- the "lazy" keyword is always included

  -- keywords specified by the user:
  kw = {}, -- example: "line" matches lualine, bufferline and indent-blankline

  -- when the name of the plugin matches keywords in both kw/preset and override_kw:
  -- invert enable_match for that plugin
  override_kw = {},
}
```

### Custom presets and settings

As an _optional_ step, the user can add custom functions for handling presets
and changing settings to the `user` section in [opts].
The following functions are used by **lazyflex**:

- presets: `get_preset_keywords(name, enable_match)`
  - `name`: the name of the preset
  - `enable_match`: true when enabling, false otherwise
  - _returns_: a `list` with keywords or `{}`
- settings: `change_settings(settings)`
  - `settings`: the settings provided in [opts](#configuration)
  - _returns_: a `spec`(used by [LazyVim]) or `{}`

These functions can be implemented in a separate module in the user's configuration.
Suggestion: Copy the example module [examples/lazyflex_collection.lua]
to the `lua` folder inside `XDG_CONFIG_HOME`(default on `linux`: `~/.config/nvim`)

_Note_: Do not use a folder [lazy.nvim] is configured to [import] from.

Example user [opts]:

```lua
user = {
  get_preset_keywords = require("flex_collection").get_preset_keywords,
  change_settings = require("flex_collection").change_settings,
  presets = {},
  settings = {},
},
```

## Minimal reproducible configurations

The plugin has two examples for writing reproducible configurations
using `lazyflex`, located in the `./repro` folder:

- [repro_lazy.lua]
- [repro_lazyvim.lua]

## About enabling and disabling

For each plugin managed by _lazy.nvim_ that is not unconditionally `disabled`,
**lazyflex** overrides its `cond` property.

The `cond` property needs to be set
before **lazy.nvim** starts taking its value into consideration.
Therefore, **lazyflex** operates in the `spec phase`.
As part of the `spec phase`, **lazy.nvim** _requires_ `lazyflex.hook`

> See: `:Lazy profile`.

A similar approach can also be found in the following code:

- [vscode.lua] in [LazyVim]
- [config.init] in [LazyVim]

**References**:

- [lazy.nvim plugin spec]
- [lazy.nvim configuration],  property `defaults.cond`

## History

The idea grew over time:

- Debug nvim crash with plugins: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1322#discussioncomment-6728171)
- Turning LazyVim into Kickstart: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1483)
- Adding to repro.lua: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1493)
- Feature: integrated binary debugging: [**lazy.nvim**](https://github.com/folke/lazy.nvim/issues/1047#issuecomment-1735131704)

## Acknowledgements

- [lazy.nvim]: The architecture, semantics and enhanced possibilities.
- [LazyVim]: The concept of a plugin as a collection of other plugins.

[lazy.nvim]: https://github.com/folke/lazy.nvim
[lazy.nvim requirements]: https://github.com/folke/lazy.nvim#%EF%B8%8F-requirements
[lazy.nvim installation]: https://github.com/folke/lazy.nvim#-installation
[lazy.nvim plugin spec]: https://github.com/folke/lazy.nvim#-plugin-spec
[lazy.nvim configuration]: https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
[import]: https://github.com/folke/lazy.nvim#%EF%B8%8F-importing-specs-config--opts
[LazyVim]: https://github.com/LazyVim/LazyVim
[LazyVim starter]: https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11
[vscode.lua]: (https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
[config.init]: https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187
[presets]: #custom-presets-and-settings
[reproducible configuration]: #minimal-reproducible-configurations
[examples]: #minimal-reproducible-configurations
[opts]: #configuration
[examples/lazyflex_spec.lua]: https://github.com/abeldekat/lazyflex.nvim/blob/main/examples/lazyflex_spec.lua
[examples/lazyflex_collection.lua]: https://github.com/abeldekat/lazyflex.nvim/blob/main/examples/lazyflex_collection.lua
[repro_lazy.lua]: https://github.com/abeldekat/lazyflex.nvim/blob/main/examples/repro_lazy.lua
[repro_lazyvim.lua]: https://github.com/abeldekat/lazyflex.nvim/blob/main/examples/repro_lazyvim.lua
