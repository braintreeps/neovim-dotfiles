# Architecture

`init.lua` loads options, keymaps, and `lazy.nvim`, then hands every plugin spec in `lua/plugins/` to `lazy.nvim`. An optional `lua/personal/` directory, which is gitignored, overlays your own options, plugins, and post-load code at three fixed points.

## Load order

`init.lua` runs these steps in order:

1. `config.options`, then `personal.options` if `lua/personal/options.lua` exists.
2. `config.keymaps`.
3. Bootstrap `lazy.nvim` into `stdpath("data")/lazy/lazy.nvim` if it is missing.
4. `require("lazy").setup` with the spec list `{ { import = "plugins" } }`. If `lua/personal/plugins` exists, `{ import = "personal.plugins" }` is inserted at index 2, after the base plugins.
5. `config.usercmds`, then `config.autocmds`.
6. `personal.init` if `lua/personal/init.lua` exists.

Existence checks use `Utils.config_path_exists` in `lua/config/utils.lua`, so a missing personal file is skipped silently.

## Directory roles

| Path | Role |
| --- | --- |
| `init.lua` | Entry point and load order. |
| `lua/config/` | Options, keymaps, autocommands, user commands, and the statusline setup (`heirline.lua`). |
| `lua/config/utils.lua` | Helper module. Submodules in `lua/config/utils/` load on first access, for example `Utils.lsp` and `Utils.treesitter`. |
| `lua/plugins/` | Plugin specs, grouped by theme (`coding.lua`, `editor.lua`, `ui.lua`, `lsp.lua`, `treesitter.lua`, `formatting.lua`, and others). `legacy.lua` holds traditional Vim plugins. |
| `ftplugin/`, `ftdetect/` | Per-filetype options and filetype detection. |
| `after/queries/` | Treesitter query overrides. |
| `scripts/` | Maintenance scripts, such as `headless-bootstrap.lua`. |
| `lazy-lock.json`, `mason-lock.json` | Pinned plugin commits and tool versions. |
| `lua/personal/` | Gitignored overlay for one user's customizations. |

## Where a new plugin spec goes

Add it to the `lua/plugins/` file that matches its purpose: `coding.lua` for completion and snippets, `editor.lua` for navigation and git, `ui.lua` for appearance, `lsp.lua` for language servers, `treesitter.lua` for parser-based features, `formatting.lua` for formatters, and `utils.lua` for general helpers. Every file returns a list of specs, and `lazy.nvim` merges them. Do not add a new file unless no existing theme fits. See [CONTRIBUTING.md](../CONTRIBUTING.md) for spec conventions and [ADDING_A_LANGUAGE.md](./ADDING_A_LANGUAGE.md) for language support.

## Personal overlay contract

The overlay has three hooks, all optional, and they run in this order:

1. `lua/personal/options.lua` runs right after `config.options` and before keymaps and plugins.
2. `lua/personal/plugins/` is imported at spec index 2. Specs there merge with base specs of the same plugin name, so `opts` can be extended and `enabled` toggled. Several base specs invite this, for example the `enabled = false` entries in `lua/plugins/ui.lua` and `lua/plugins/coding.lua`.
3. `lua/personal/init.lua` runs last, after plugins are set up and after `config.usercmds` and `config.autocmds`.

Base code must never `require` a personal module unconditionally. Guard it with `Utils.config_path_exists`, as `init.lua` does. The `lua/personal` directory is listed in `.gitignore`, so it is never committed to this repository.

## Lockfiles

Two lockfiles pin plugins and tools, and the personal overlay keeps its own plugin lockfile.

- **`lazy-lock.json`** pins plugin commits. `cosmicbuffalo/super_lazy.nvim` (declared in `lua/plugins/utils.lua`) manages it through `lockfile_repo_dirs`, which lists the config directory and `lua/personal`. The base repository and the personal overlay each get a separate lockfile, so personal plugins never change the base lockfile.
- **`mason-lock.json`** pins tool versions. `cosmicbuffalo/mason-lock.nvim` (declared in `lua/plugins/lsp.lua`) writes it with `lockfile_scope = "locked_packages"`, so only the packages in `locked_packages` are recorded. Add a tool there if it must be reproducible.
- **`folke/lazy.nvim`** is itself pinned to stable releases in `lua/plugins/utils.lua` and is excluded from updates.

Run `:Lazy` to update plugins, and commit the changed lockfile with the change that needed it.
