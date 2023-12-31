# Changelog

## [4.0.0](https://github.com/abeldekat/lazyflex.nvim/compare/v3.1.0...v4.0.0) (2023-10-30)


### ⚠ BREAKING CHANGES

* **core:** simplify the design and the readme ([#66](https://github.com/abeldekat/lazyflex.nvim/issues/66))

### Code Refactoring

* **core:** simplify the design and the readme ([#66](https://github.com/abeldekat/lazyflex.nvim/issues/66)) ([4539415](https://github.com/abeldekat/lazyflex.nvim/commit/453941556437339ab17cd20926c42225ace6e50a))

## [3.1.0](https://github.com/abeldekat/lazyflex.nvim/compare/v3.0.0...v3.1.0) (2023-10-29)


### Features

* **extras:** added filter_import ([#62](https://github.com/abeldekat/lazyflex.nvim/issues/62)) ([81c85e7](https://github.com/abeldekat/lazyflex.nvim/commit/81c85e7ed0d29a1de01c61f5a22b18c0c0bf43ec))

## [3.0.0](https://github.com/abeldekat/lazyflex.nvim/compare/v2.3.0...v3.0.0) (2023-10-16)


### ⚠ BREAKING CHANGES

* **core:** Split lazyflex.hook and remove the collection option  ([#57](https://github.com/abeldekat/lazyflex.nvim/issues/57))

### Code Refactoring

* **core:** Split lazyflex.hook and remove the collection option  ([#57](https://github.com/abeldekat/lazyflex.nvim/issues/57)) ([2d977ba](https://github.com/abeldekat/lazyflex.nvim/commit/2d977ba23558556b18704309fc90f3b2388e657d))

## [2.3.0](https://github.com/abeldekat/lazyflex.nvim/compare/v2.2.0...v2.3.0) (2023-10-15)


### Features

* **core:** add override_kw ([#53](https://github.com/abeldekat/lazyflex.nvim/issues/53)) ([218d29e](https://github.com/abeldekat/lazyflex.nvim/commit/218d29e6a2773c4748cac156401eda73504a7893))

## [2.2.0](https://github.com/abeldekat/lazyflex.nvim/compare/v2.1.4...v2.2.0) (2023-10-13)


### Features

* **core:** implemented config settings for the user. ([#50](https://github.com/abeldekat/lazyflex.nvim/issues/50)) ([b365f9d](https://github.com/abeldekat/lazyflex.nvim/commit/b365f9d87b42a20fe63f61f41aee9a459e5c7bcc))

## [2.1.4](https://github.com/abeldekat/lazyflex.nvim/compare/v2.1.3...v2.1.4) (2023-10-13)


### Bug Fixes

* **core:** handle plugin.optional and always set plugin.cond when plugin is enabled ([#48](https://github.com/abeldekat/lazyflex.nvim/issues/48)) ([aa1ccb4](https://github.com/abeldekat/lazyflex.nvim/commit/aa1ccb445a4ebd9fb6869d7317c0e0c69830d033))

## [2.1.3](https://github.com/abeldekat/lazyflex.nvim/compare/v2.1.2...v2.1.3) (2023-10-12)


### Bug Fixes

* **lazyvim:** v10 incorporate changes ([#45](https://github.com/abeldekat/lazyflex.nvim/issues/45)) ([691e14f](https://github.com/abeldekat/lazyflex.nvim/commit/691e14faec5e1ee12ffc7ee52f68a420aaa3a756))

## [2.1.2](https://github.com/abeldekat/lazyflex.nvim/compare/v2.1.1...v2.1.2) (2023-10-12)


### Bug Fixes

* **core:** lazyflex must skip disabled plugins ([#41](https://github.com/abeldekat/lazyflex.nvim/issues/41)) ([773bedd](https://github.com/abeldekat/lazyflex.nvim/commit/773beddc091f09913205d4c10bf1ab83da28c24d))

## [2.1.1](https://github.com/abeldekat/lazyflex.nvim/compare/v2.1.0...v2.1.1) (2023-10-10)


### Bug Fixes

* **core:** error in lazyflex when opts is a function ([#39](https://github.com/abeldekat/lazyflex.nvim/issues/39)) ([780833b](https://github.com/abeldekat/lazyflex.nvim/commit/780833bc5eda7d0009c810bdc8e9a9606ffcf621))

## [2.1.0](https://github.com/abeldekat/lazyflex.nvim/compare/v2.0.0...v2.1.0) (2023-10-10)


### Features

* **core:** remove the target_property from the options: Always use cond ([#29](https://github.com/abeldekat/lazyflex.nvim/issues/29)) ([0721a69](https://github.com/abeldekat/lazyflex.nvim/commit/0721a696aa8813305da28778a06288fb1921e5e9))


### Bug Fixes

* lazyvim 9.7.0 lazyvim.plugins.core is now lazyvim.plugins.init ([#34](https://github.com/abeldekat/lazyflex.nvim/issues/34)) ([b50379f](https://github.com/abeldekat/lazyflex.nvim/commit/b50379f4f5f470ce792ccfdb694a587b29f53998))
* **lazyvim:** new version adds telescope-fzf-native ([#35](https://github.com/abeldekat/lazyflex.nvim/issues/35)) ([8be70ad](https://github.com/abeldekat/lazyflex.nvim/commit/8be70add676b52b3730ce2eed8cdc2587d71e012))
* **lazyvim:** v9.8.0 cmp-nvim-lsp moved to coding ([#33](https://github.com/abeldekat/lazyflex.nvim/issues/33)) ([7ef79ae](https://github.com/abeldekat/lazyflex.nvim/commit/7ef79aedb459e7413ecad6a1dd568f769d48f7c3))

## [2.0.0](https://github.com/abeldekat/lazyflex.nvim/compare/v1.0.0...v2.0.0) (2023-10-09)


### ⚠ BREAKING CHANGES

* changed the names of several options. Changed the import hook. ([#22](https://github.com/abeldekat/lazyflex.nvim/issues/22))

### Code Refactoring

* changed the names of several options. Changed the import hook. ([#22](https://github.com/abeldekat/lazyflex.nvim/issues/22)) ([a24235b](https://github.com/abeldekat/lazyflex.nvim/commit/a24235b94a33f753db1f6e19d69a8f5a61b9b816))

## 1.0.0 (2023-10-07)


### Features

* bail-out when user does not supply any options. ([350e3ef](https://github.com/abeldekat/lazyflex.nvim/commit/350e3effcfa05a086d7db908f06f7a8d3f335423))
* ci, added e2e to test lazyflex.nvim and lazy.nvim integration. ([79ef9c3](https://github.com/abeldekat/lazyflex.nvim/commit/79ef9c3cd0d2db7c94c51843aadeceff4015b455))
* easier preset configuration for the user. Also changed: Opt-out when there are no keywords to enable or disable ([337c5e5](https://github.com/abeldekat/lazyflex.nvim/commit/337c5e5f6482fcf15520916dd66348a09fee012e))
* easier preset configuration for the user. Also changed: Opt-out when there are no keywords to enable or disable ([27cb562](https://github.com/abeldekat/lazyflex.nvim/commit/27cb5625d941e96dcab9932ad934c9d187a192bb))
* simplify installation instructions, see lazy.nvim pr [#1079](https://github.com/abeldekat/lazyflex.nvim/issues/1079) ([c022bb0](https://github.com/abeldekat/lazyflex.nvim/commit/c022bb0465c90b3089978a008e024e471f8e2b4c))
