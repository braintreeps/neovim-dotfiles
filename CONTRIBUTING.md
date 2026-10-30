# Contributing

Keep changes small, formatted with `stylua`, and described in the commit message rather than in code comments. For how the configuration fits together, read [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) first.

## Plugin specs

Every plugin spec in `lua/plugins/` declares what loads it: `event`, `cmd`, `ft`, or `keys`. For file-opening triggers, reuse `Utils.lazy.LazyFileEvents` from `lua/config/utils/lazy.lua`.

`lazy = false` needs a reason a maintainer can verify, such as a colorscheme that must apply at startup or a plugin that must register state before any trigger can fire. Existing examples are in `lua/plugins/colorscheme.lua` and `lua/plugins/utils.lua`. State the reason in the commit message or PR text.

Put the spec in the file that matches its purpose (see [Where a new plugin spec goes](./docs/ARCHITECTURE.md#where-a-new-plugin-spec-goes)). Do not edit `lazy-lock.json` by hand. Update it through `:Lazy`, and commit it with the change that required it.

## Comments

Default to no inline comments. Explain why a change was made in the commit message or PR description. Add a short comment only when a reader could not reconstruct something on their own, such as a non-obvious invariant, a workaround for a specific external bug, or a footgun.

## Formatting

The Lint workflow in `.github/workflows/lint.yml` runs `stylua --check .` on every PR and on pushes to `main`. Run the same command locally before committing:

```sh
stylua --check .
```

Indentation rules for Lua, Markdown, and JSON are in `.editorconfig`.

## Commits and pull requests

Use conventional commits for both commit subjects and PR titles, for example `feat(treesitter): Enable C parsing` or `fix: Fix Python LSP`. Make each commit one logical change, and describe the why in the body.
