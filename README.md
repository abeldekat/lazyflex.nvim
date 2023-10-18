# lazyflex.nvim

**lazyflex.nvim** is an add-on for [**lazy.nvim**](https://github.com/folke/lazy.nvim), a modern plugin manager for Neovim.

Its main objective is to make it easier to test and troubleshoot a `neovim` configuration.

## Demo

https://github.com/abeldekat/lazyflex.nvim/assets/58370433/1bb1ba01-b6a3-4753-b3d7-e05bc1cd1ce7

> The code used in the demo can be found [here](https://github.com/abeldekat/starter/blob/lazyflex_demo/lua/config/lazyflex_test.lua)

## Features

- Easier troubleshooting/testing from one central location.
  - Enable/disable multiple plugins by keyword.
  - Define and use [presets](#custom-presets-and-settings) for your own configuration.
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
      cond = true,
      import = "lazyflex.entry.lazyvim", -- when using LazyVim
      -- import = "lazyflex.entry.lazy", -- or: when only using lazy.nvim
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

**References**:

- Installation section: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-installation)
- `config.lazy`: [**LazyVim starter**](https://github.com/LazyVim/starter/blob/a13d5c90769ce6177d1e27b46efd967ed52c1d68/lua/config/lazy.lua#L11)

## Concepts

**lazyflex**:

1. Returns immediately when there are no keywords or presets supplied to _enable_ or _disable_
2. Only operates on plugins that are not unconditionally disabled(`plugin.enabled = false`)

### Important properties

- `kw`: a list of words matching names of plugins.
- `preset`: a _predefined_ list of words matching names of plugins
- `enable_match`:
  - `true`(_enable_ incrementally, default): _enable_ all plugins that match keywords, _disable_ the others.
  - `false`(_disable_ incrementally): _disable_ all plugins that match keywords, _enable_ the others
- `override_kw`: invert `enable_match` on a plugin when its name has a match
in both this list of words **and** in `kw` including `presets` 

## Colorscheme

_Important_: The name of the colorscheme must be in the keywords when `enabling`

Alternatively:

1. Add the name to property [kw_always_enable](#configuration) : `kw_always_enable = { "name-of-colorscheme"}`
2. When using **LazyVim**: Use the `colorscheme` preset.
3. When using [custom presets](#adding-custom-presets): Create a `colorscheme` preset.

## Examples

### Using a personal configuration

The plugin can be used when your personal configuration is not build upon
a community setup like **LazyVim**.

Add to the [spec](#installation):

> `import = "lazyflex.entry.lazy"`

```lua
  -- Enable: harpoon, plenary and tokyonight
  -- Disable: all other plugins
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazy",
    opts = { kw = { "har", "plen", "tokyo" } },
  },

  -- Disable: telescope and harpoon
  -- Enable: all other plugins
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazy",
    opts = { enable_match = false, kw = { "tele", "har" } },
  },
```

### Using a community setup like LazyVim

> Prerequisite: Add **LazyVim** to your [plugin spec](#installation)

_Note_: A preset setting that does not match a predefined preset will be ignored.

Add to the [spec](#installation):

> `import = "lazyflex.entry.lazyvim"`
```lua
  -- New plugin: harpoon
  -- Plugins: approximately 40 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = { kw = { "har", "plenary", "tokyo" } },
  },

  -- Lazyvim: telescope and the following modules: coding, colorscheme
  -- Plugins: approximately 30 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      lazyvim = { presets = { "coding", "colorscheme" } },
      kw = { "tele", "plen" },
    },
  },

  -- LazyVim: disable telescope and all plugins in the lsp module
  -- Plugins: approximately 10 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      enable_match = false,
      lazyvim = { presets = { "lsp" } },
      kw = { "tele" },
    },
  },

  -- Lazyvim: enable plugins in the editor module and plugins matching `cmp`,
  -- except plugins that are also matched against `override_kw`
  -- Plugins: approximately 30 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      kw_always_enable = { "tokyo" }, -- always enable your colorscheme
      lazyvim = { presets = { "editor" } },
      kw = { "cmp" },
      --  don't enable: "nvim-spectre", "flash.nvim" and "cmp_luasnip"
      override_kw = { "spectre", "fla", "luasn" },
    },
  },

```

### Reusing specs from a collection of plugins

**LazyVim** can be used without loading its options, autocommands and keymappings.
The settings of the resulting configuration will default to stock Neovim.

This can be useful during testing or when reporting an issue for one of the plugins,
instead of adding the full spec to a [reproducible configuration](#minimal-reproducible-configurations)

> Prerequisite: Add **LazyVim** to your [plugin spec](#installation)

Add to the [spec](#installation):

> `import = "lazyflex.entry.lazyvim"`

Add to the options:

> `lazyvim = { settings = { enabled = false } }`

```lua
  -- LazyVim: very minimal...
  -- Plugins: lazy.nvim, LazyVim, tokyonight
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      lazyvim = { settings = { enabled = false } },
      kw = { "tokyo" },
    },
  },

  -- LazyVim: telescope spec and the colorscheme module
  -- Plugins: lazy.nvim, LazyVim, tokyonight, catppuccin, telescope, plenary
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      lazyvim = { settings = { enabled = false }, presets = { "colorscheme" } },
      kw = { "tele", "plen" },
    },
  },

  -- LazyVim: all specs except the ones defined in UI
  -- Plugins: approximately 10 disabled
  {
    "abeldekat/lazyflex.nvim",
    import = "lazyflex.entry.lazyvim",
    opts = {
      enable_match = false,
      lazyvim = { settings = { enabled = false }, presets = { "ui" } },
    },
  },
```

## Configuration

**lazyflex.nvim** comes with the following defaults:

```lua
{
  -- lazyvim collection
  lazyvim = {
    -- any lazyvim.presets specified that don't match have no effect:
    presets = {}, -- example: { "coding" }: matches all plugins in the coding module

    -- load lazyvim's settings by default:
    settings = {
      enabled = true, -- quick switch. Disables the three options below:
      options = true, -- use config.options
      autocmds = true, -- use config.autocmds
      keymaps = true, -- use config.keymaps
    },
  },

  -- user collection
  user = {
    -- lazyflex.collections.stub is used by default as a pass-through

    -- 1. optional: functions overriding lazyflex.collections.stub
    get_preset_keywords = nil,
    change_settings = nil,

    -- 2. optional: a user module, "required" automatically
    -- the module should contain an implementation of lazyflex.collections.stub
    -- use lazyflex.collections.lazyvim as an example
    mod = "config.lazyflex",

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

As an *optional* step, the user can add custom functions for handling presets and changing settings.
The following functions are used by **lazyflex**:

1. presets: `get_preset_keywords(name, enable_match)`
  - `name`: the name of the preset
  - `enable_match`: true when enabling, false otherwise
  - *returns*: a `list` with keywords or `{}`
2. settings: `change_settings(settings)`
  - `settings`: the settings provided in [opts](#configuration)
  - *returns*: a `spec`(used by **LazyVim**) or `{}`

_Note_: User presets will only apply when the module is correctly implemented and are otherwise ignored.

Add to the options:

> `user = { presets = { "coding", "editor"} }`

The user can add custom code directly into the [opts](#configuration): 

```lua
user = {
  get_preset_keywords = function(name, enable_match) return {} end,
  change_settings = function(settings) return {} end,
  settings = { -- passed into function change_settings:
    enabled = true, -- quick switch. Disables the three options below:
    options = true,
    autocmds = true,
    keymaps = true,
  },
},
```

Alternatively, the user can add a `lua` module to the configuration:

> Example: Copy the lazyflex module [`lazyflex.collections.stub`](https://github.com/abeldekat/lazyflex.nvim/blob/main/lua/lazyflex/collections/stub.lua)
> to `your-neovim-config-folder/lua/config/lazyflex.lua`

When the user module is not present, **lazyflex** falls back to [lazyflex.collections.stub.](https://github.com/abeldekat/lazyflex.nvim/blob/main/lua/lazyflex/collections/stub.lua)
The path and the name of the module can be changed:

> user = { mod = "inside-your-lua-folder.another-name"}

_Note_: Do not use a folder `lazy.nvim` [imports](https://github.com/folke/lazy.nvim#%EF%B8%8F-importing-specs-config--opts) from.

Example implementation:

```lua
local M = {}

local presets = {
  editor = { "harpoon" }, -- add more plugins
  -- add more presets
}

-- enable_match=true: harpoon needs plenary
-- enable_match=false: plenary should not be disabled
local when_enabling = {
  editor = { "plenary" },
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

M.change_settings = function(settings)
  if settings.options == false then
    package.loaded["config.options"] = true
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
  end
  if settings.autocmds == false then
    package.loaded["config.autocmds"] = true
  end
  if settings.keymaps == false then
    package.loaded["config.keymaps"] = true
  end
  return {}
end

return M
```

## Minimal reproducible configurations

The plugin has two examples for writing reproducible configurations
using `lazyflex`, located in the `./repro` folder:

- [`repro_lazy.lua`](https://github.com/abeldekat/lazyflex.nvim/blob/main/repro/repro_lazy.lua)
- [`repro_lazyvim.lua`](https://github.com/abeldekat/lazyflex.nvim/blob/main/repro/repro_lazyvim.lua)

## About enabling and disabling

For each plugin managed by _lazy.nvim_ that is not unconditionally `disabled`,
**lazyflex** overrides its `cond` property.

The `cond` property needs to be set before **lazy.nvim** starts taking its value into consideration.
Therefore, **lazyflex** operates in the `spec phase`.

> See: `:Lazy profile`. As part of the `spec phase`, **lazy.nvim** _requires_ the `import`

A similar approach can also be found in the following code:

- `vscode.lua`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/plugins/extras/vscode.lua#L24)
- `config.init`: [**LazyVim**](https://github.com/LazyVim/LazyVim/blob/3acdac917b79e22b1c3420aabde8b583d0799f6a/lua/lazyvim/config/init.lua#L187)

**References**:

- Plugin Spec: [**lazy.nvim**](https://github.com/folke/lazy.nvim#-plugin-spec)
- Configuration `defaults.cond`: [**lazy.nvim**](https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration)

## History

The idea grew over time:

- Debug nvim crash with plugins: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1322#discussioncomment-6728171)
- Turning LazyVim into Kickstart: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1483)
- Adding to repro.lua: [**LazyVim** discussion](https://github.com/LazyVim/LazyVim/discussions/1493)
- Feature: integrated binary debugging: [**lazy.nvim**](https://github.com/folke/lazy.nvim/issues/1047#issuecomment-1735131704)

## Acknowledgements

- [**lazy.nvim**](https://github.com/folke/lazy.nvim): The architecture, semantics and enhanced possibilities.
- [**LazyVim**](https://github.com/LazyVim/LazyVim): The concept of a plugin as a collection of other plugins.
