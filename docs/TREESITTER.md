# Treesitter Setup and Configuration Guide

This guide explains how Treesitter works in this Neovim config and how to customize it for your needs.

## What is Treesitter?

Treesitter is a parser generator tool that builds syntax trees for source code. Unlike traditional vim syntax highlighting that relies on complex regular expressions, treesitter creates an actual parse tree of your code. This provides:

- **Superior syntax highlighting** - More accurate and context-aware colors, especially for deeply nested or complex languages
- **Intelligent text objects** - Better understanding of code structure for navigation and selection
- **Incremental parsing** - Fast updates as you type with minimal performance impact
- **Language-agnostic approach** - Consistent experience across all supported programming languages
- **Enhanced code folding** - Structure-aware code folding based on syntax
- **Better indentation** - Context-aware automatic indentation

Think of it as having a deep understanding of your code's structure, enabling much smarter editing features.

## Currently Supported Languages

This config comes pre-configured with treesitter parsers for common languages including:

- **Shell**: `bash`
- **Systems and JVM**: `c`, `cmake`, `go`, `java`, `kotlin`, `groovy`, `rust`
- **Web**: `html`, `javascript`, `typescript`, `tsx`
- **Data and config**: `json`, `yaml`, `toml`, `properties`, `proto`, `jq`, `cue`
- **Infrastructure**: `terraform`, `hcl`, `dockerfile`, `puppet`
- **Ruby**: `ruby`, `embedded_template`
- **Editor and docs**: `lua`, `luadoc`, `markdown`, `markdown_inline`, `vim`, `vimdoc`
- **Git and SSH files**: `diff`, `git_config`, `git_rebase`, `gitignore`, `ssh_config`
- **Other**: `python`, `sql`, `http`

The source of truth is `ensure_installed` in `lua/config/utils/treesitter.lua`.

## How It Works

### Manual Management
- **`:checkhealth nvim-treesitter`** - See which parsers are installed
- **`:TSUpdate`** - Update all installed parsers
- **`:lua vim.treesitter.stop()`** - Turn off treesitter highlighting for the current buffer

### Installing Parsers

#### **Recommended way**

If you haven't already, create a
[personal scaffold](https://github.com/braintreeps/neovim-dotfiles-personal.scaffold)
and add a spec in there with the languages that you want to add, as well as any
other configuration
```lua
-- EXAMPLE
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "cue",
    },
    textobjects = {
      move = {
        goto_next_start = { ["]m"] = "@function.outer" }
      },
    },
  },
},
```

You can also install manually
1. Install a parser: `:TSInstall <language>`
   - Example: `:TSInstall go` for Go language support
2. Check installation: `:checkhealth nvim-treesitter`
3. Update if needed: `:TSUpdate <language>`

or add the parser to the `ensure_installed` property in the setup function in the treesitter plugin config
```lua
ensure_installed = {
    -- add more here
    "bash",
    "ruby",
    "lua",
    "dockerfile",
    ...
},
```

### Available Parsers
For a complete list of available parsers, see the [official parser list](https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers).

Popular parsers include:
- **Ruby**: `ruby`
- **Java**: `java`
- **React JSX**: `tsx`
- **Go**: `go`
- **C/C++**: `c`, `cpp`

### Highlighting Configuration
Current settings live in `lua/plugins/treesitter.lua`

### Text Objects Configuration
Treesitter provides intelligent text objects for selecting code structures:

```lua
textobjects = {
    select = {
        enable = true,
        keymaps = {
            ["ac"] = { query = "@class.outer", desc = "Select around class" },
            ["ic"] = { query = "@class.inner", desc = "Select inside class" },
            ["af"] = { query = "@function.outer", desc = "Select around function" },
            ["if"] = { query = "@function.inner", desc = "Select inside function" },
            ["al"] = { query = "@loop.outer", desc = "Select around loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inside loop" },
            ["ab"] = { query = "@block.outer", desc = "Select around block" },
            ["ib"] = { query = "@block.inner", desc = "Select inside block" },
        },
        selection_modes = {
            ["@class.outer"] = "V",
        },
    },
    move = {
        enable = true,
        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
        goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
    },
},
```

## Using Treesitter Features

### Text Objects
Once configured, you can use treesitter text objects for precise selections:
- **`vaf`** - Select entire function (including definition)
- **`vif`** - Select function body only
- **`dac`** - Delete entire class
- **`yic`** - Copy class contents

### Navigation
- **`]f`** - Jump to next function
- **`[f`** - Jump to previous function
- **`]c`** - Jump to next class
- **`[c`** - Jump to previous class

## Troubleshooting

### Parser Won't Install?
1. Check internet connection
2. Try updating treesitter: `:TSUpdate`
3. Check system dependencies (C compiler required)
4. View installation logs: `:messages`

### Performance Issues?
1. Check parser status: `:checkhealth nvim-treesitter`
2. Turn off highlighting for the current buffer: `:lua vim.treesitter.stop()`
3. Reduce parser features in config:
```lua
opts = {
  highlight = { enable = true },
  indent = { enable = false },      -- Disable if causing issues
  fold = { enable = false },        -- Disable if causing issues
}
```

### Wrong Language Detection?
1. Check file extension is correct
2. Force filetype: `:set filetype=<language>`
3. Verify parser exists: `:checkhealth nvim-treesitter`

## Learning More

- **Treesitter documentation**: `:help treesitter`
- **nvim-treesitter plugin**: [GitHub repository](https://github.com/nvim-treesitter/nvim-treesitter)
- **Available parsers**: [Tree-sitter parser list](https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers)
- **Text objects**: `:help nvim-treesitter-textobjects`

## Quick Reference

| Action | Command | Description |
|--------|---------|-------------|
| Install parser | `:TSInstall <lang>` | Install parser for language |
| Update parsers | `:TSUpdate` | Update all installed parsers |
| Check status | `:checkhealth nvim-treesitter` | See installed parsers |
| Stop highlighting | `:lua vim.treesitter.stop()` | Disable for current buffer |
| View logs | `:messages` | Debug installation issues |
| Inspect tree | `:InspectTree` | Interactive syntax tree explorer |
