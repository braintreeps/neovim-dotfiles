# Adding a language

Adding a language takes up to three edits: a server and tooling entry in `lua/plugins/lsp.lua`, a parser name in `lua/config/utils/treesitter.lua`, and a formatter in `lua/plugins/formatting.lua`. This guide uses Rust as the worked example. The `rust` parser is already in `ensure_installed`, so only the other two edits are needed.

## 1. Language server and tools

Edit the `opts` of `neovim/nvim-lspconfig` in `lua/plugins/lsp.lua`. Two tables work together:

- `server_defs` maps a language server name, the string `vim.lsp.enable` accepts, to its configuration. The optional `mason` key names the Mason package when it differs from the server name, and `mason = false` means Mason does not install it.
- `filetype_tooling` maps a filetype to the `servers` and `tools` installed when a buffer of that filetype opens.

Every name in `filetype_tooling[*].servers` must be a key in `server_defs`. A missing key shows an error titled `lsp-contract`.

```lua
server_defs = {
    -- existing entries...
    rust_analyzer = { mason = "rust-analyzer" },
},
filetype_tooling = {
    -- existing entries...
    rust = {
        servers = { "rust_analyzer" },
    },
},
```

Servers installed through gems instead of Mason use the `gems` map, as the `ruby` entry does.

## 2. Treesitter parser

Add the parser name to `M.ensure_installed` in `lua/config/utils/treesitter.lua`, keeping the list alphabetical. For Rust, `"rust"` is already present, so nothing changes. For a language that is missing, add one string, such as `"zig"`.

## 3. Formatter

Add the filetype to `formatters_by_ft` in the `opts` of `stevearc/conform.nvim` in `lua/plugins/formatting.lua`:

```lua
formatters_by_ft = {
    -- existing entries...
    rust = { "rustfmt" },
},
```

`conform.nvim` runs `rustfmt` from your `PATH`; it is not installed through Mason here. If the formatter is a Mason package, also list it under `tools` in `filetype_tooling` so it installs on demand.

Format on save is off by default and enabled per filetype in `format_on_save`, which currently covers `go`, `terraform`, and `hcl`. Everywhere else, format with `<leader>F`.

## 4. Pin the tool version

If a Mason-managed formatter must be reproducible across machines, add its package name to `locked_packages` in the `mason-lock.nvim` options in `lua/plugins/lsp.lua`, then commit the resulting `mason-lock.json` change.

## Check the result

Open a file of the new filetype. Mason installs the server in the background. `<Leader>ci` shows the attached server, and `:ConformInfo` shows the formatter. Run `stylua --check .` before committing.
