# LSP Setup and Configuration Guide

This guide explains how Language Server Protocol (LSP) works in this Neovim config and how to customize it for your needs.

## What is LSP?

LSP (Language Server Protocol) is what makes Neovim "smart" about your code. It provides:
- **Syntax highlighting** and error detection
- **Go to definition** and find references
- **Auto-completion** and code suggestions
- **Refactoring tools** like rename and code actions
- **Real-time error checking** as you type

Think of it as having a programming language expert looking over your shoulder, helping you write better code.

## Currently Supported Languages

This config comes pre-configured with LSP support for:

- **Bash/Shell scripts** (`bashls`)
- **Go** (`gopls`)
- **Lua** (`lua_ls`)
- **Python** (`basedpyright`)
- **Ruby** (`ruby_lsp`, `rubocop`)
- **Terraform** (`terraformls`)
- **TypeScript/JavaScript** (`ts_ls`)
- **YAML** (`yamlls`)

The source of truth is `server_defs` and `filetype_tooling` in `lua/plugins/lsp.lua`.

## How It Works

### Automatic Installation
When you first open a file in a supported language, the LSP server is automatically:
1. Downloaded and installed via [Mason](https://github.com/mason-org/mason.nvim)
2. Configured with sensible defaults
3. Started and connected to your file

### Manual Management
- **`:Mason`** / **`<Leader>cm`** - Open Mason to manage language servers
- **`:LspInfo`** - See which servers are running for current file

## Adding New Languages

Language support is declared in two tables under `opts` for `"neovim/nvim-lspconfig"` in `lua/plugins/lsp.lua`:

- `server_defs` — one entry per language server, keyed by the server name that `vim.lsp.enable` accepts. The entry holds any custom config for the server, plus an optional `mason` field with the Mason package name when it differs from the server name (use `mason = false` for servers that Mason doesn't install).
- `filetype_tooling` — per-filetype tooling that is installed on demand the first time you open a file of that type. Each entry can list `servers` (keys of `server_defs`), `tools` (Mason formatters and linters), and `gems` (gem name to server name, for servers installed through `gem install`).

Every server named in `filetype_tooling` must exist in `server_defs`. If one doesn't, you'll see an `lsp-contract` error notification when you open that filetype.

To add a language, create or open `~/.config/nvim/lua/personal/plugins/lsp.lua` and add both tables:

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      server_defs = {
        rust_analyzer = {
          mason = "rust-analyzer",
          -- add any custom config for your server here
        },
      },
      filetype_tooling = {
        rust = {
          servers = { "rust_analyzer" },
        },
      },
    },
  },
}
```

You can find Mason package names by pressing `/` in `:Mason` (`<Leader>cm`).

> [!NOTE]
> If you think your new LSP server would be useful for others and should be a Braintree default LSP server, feel free to open a PR that adds it to `server_defs` and `filetype_tooling` in [lua/plugins/lsp.lua](../lua/plugins/lsp.lua).

### Popular Language Servers
- **JavaScript/TypeScript**: `tsserver` or `ts_ls`
- **Python**: `pyright` or `pylsp`
- **Go**: `gopls`
- **Rust**: `rust_analyzer`
- **Java**: `jdtls`
- **C/C++**: `clangd`
- **HTML/CSS**: `html`, `cssls`
- **JSON**: `jsonls`

## Configuration Options

### Diagnostics (Error Display)
These settings currently live in `lua/plugins/lsp.lua` and can also be customized in your own `lua/personal/plugins/lsp.lua` to your liking:
```lua
-- This `diagnostics` key lives at the same level as `servers`, just under `opts` for the "neovim/nvim-lspconfig" plugin
diagnostics = {
  severity_sort = true,           -- Show errors before warnings
  float = {
    border = "rounded",         -- Rounded popup borders
    source = "if_many"          -- Show source if multiple available
  },
  underline = {
    severity = vim.diagnostic.severity.ERROR  -- Only underline errors
  },
}
```

### Server-Specific Settings
Example for Lua language server:
```lua
-- Again, this config is directly under `opts` for the "neovim/nvim-lspconfig" plugin
server_defs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          unusedLocalExclude = { "_*" },  -- Allow unused vars starting with _
        },
        workspace = {
          checkThirdParty = false,        -- Don't check third-party libs
        },
      },
    },
  },
},
```

## Customizing Keymaps

All LSP keymaps are defined in `lua/plugins/lsp.lua`. To customize them, add your own `keymap` section to the `opts` for `"neovim/nvim-lspconfig"`:

```lua
opts = {
    keymap = {
        go_to_definition = "gd",        -- Change this to customize
        hover = "K",                    -- Documentation popup
        lsp_rename = "<Leader>cr",      -- Rename symbol
        lsp_code_action = "<Leader>ca", -- Show fixes/actions
        -- ... other keymaps
    },
}
```

## Troubleshooting

### LSP Not Working?
1. Check if server is installed: `<Leader>cm` and make sure your server is in the "Installed" section
2. Check if server is running: `:LspInfo`
3. Restart LSP: `:LspRestart`
4. Check LSP logs for issues: `:LspLog`

### Server Won't Install?
1. Check internet connection
2. Try installing manually: `<Leader>cm` → find server → press `i`
3. Check Mason logs: `:MasonLog`

### Wrong Language Detection?
1. Check file extension is correct (`.rb` for Ruby, `.lua` for Lua, etc.)
2. Force file type: `:set filetype=ruby`

### Performance Issues?
1. Check LSP logs with `:LspLog`
2. Turn off LSP with `:LspStop`

## Advanced Configuration

### Custom Server Setup
Each `server_defs` entry is passed to `vim.lsp.config(server, config)`, so any field that Neovim's LSP client accepts works there, including `cmd`, `settings`, `on_init`, and `on_attach`:
```lua
server_defs = {
  your_new_server_name_here = {
    cmd = { "your-server", "--stdio" },
    on_init = function(client)
      -- Run whatever lua code you need to run here
    end,
  },
},
```

## Learning More

- **Mason documentation**: `:help mason.nvim`
- **LSP documentation**: `:help lsp`
- **Available servers**: [Mason registry](https://mason-registry.dev/registry/list)
- **Server configs**: [nvim-lspconfig server docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

## Quick Reference

| Action | Keymap | Description |
|--------|--------|-------------|
| Manage servers | `<Leader>cm` or `:Mason` | Open Mason |
| Check status | `:LspInfo` | See running servers |
| Restart LSP | `:LspRestart` | Restart all servers |
| Stop LSP | `:LspStop` | Stop LSP servers |
| Mason logs | `:MasonLog` | Debug installation issues |
| LSP logs | `:LspLog` | Debug LSP issues |
