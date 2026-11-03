# Contributing

Keep changes small, formatted with `stylua`, and described in the commit message rather than in code comments. For how the configuration fits together, read [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) first.

## Plugin specs

New plugin specs in `lua/plugins/` declare what loads them: `event`, `cmd`, `ft`, or `keys`. For file-opening triggers, reuse `Utils.lazy.LazyFileEvents` from `lua/config/utils/lazy.lua`. Some existing specs predate this convention.

`lazy = false` needs a reason a maintainer can verify, such as a colorscheme that must apply at startup or a plugin that must register state before any trigger can fire. Examples are in `lua/plugins/colorscheme.lua` and `lua/plugins/utils.lua`. State the reason in the commit message or PR text.

A spec with no trigger also loads at startup. `init.lua` does not set `defaults.lazy`, so lazy.nvim's default of `lazy = false` applies, and the spec needs the same justification as an explicit `lazy = false`.

Put the spec in the file that matches its purpose (see [Where a new plugin spec goes](./docs/ARCHITECTURE.md#where-a-new-plugin-spec-goes)). Do not edit `lazy-lock.json` by hand. Update it through `:Lazy`, and commit it with the change that required it.

## Comments

Default to no inline comments. Explain why a change was made in the commit message or PR description. Add a short comment only when a reader could not reconstruct something on their own, such as a non-obvious invariant, a workaround for a specific external bug, or a footgun.

## Formatting

The Lint workflow in `.github/workflows/lint.yml` runs `stylua --check .` on every PR and on pushes to `main`. Run the same command locally before committing:

```sh
stylua --check .
```

Indentation rules for Lua, Markdown, and JSON are in `.editorconfig`.

The help file is `doc/braintree-neovim.txt`, read with `:help braintree-neovim`. Neovim only finds its tags in `doc/tags`, which is committed, so regenerate it whenever you edit the help file. From the repository root, run `:helptags doc` inside Neovim, or run this from a shell:

```sh
nvim --clean --headless -c "helptags doc" -c q
```

Then commit `doc/tags` with the help file change, and check it with `:help braintree-neovim`.

## Checking your changes

Run `:checkhealth braintree-neovim` in Neovim before opening a pull request. It checks the language server configuration, the lockfiles, the treesitter parsers, and the personal overlay, and gives advice for every warning and error. The `smoke` job in `.github/workflows/lint.yml` runs the same check.

## Regenerating the cheatsheet

`CHEATSHEET.md` is generated from the keymaps and plugin specs, and the `smoke` job fails if it is out of date. Regenerate it after changing a keymap, or any file it links to, with the generator's script and commit the result:

```sh
nvim --headless -l scripts/ci/cheatsheet.lua
```

Do not use `:CheatsheetGenerate` or the pre-commit hook from `:CheatsheetInstallHook` for this. They add an `Up to date as of:` line that the script removes, so the file would fail the check.

## Commits and pull requests

Use conventional commits for both commit subjects and PR titles, for example `feat(treesitter): Enable C parsing` or `fix: Fix Python LSP`. Make each commit one logical change, and describe the why in the body.
