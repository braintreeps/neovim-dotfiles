-- Legacy filetype packs: syntax, indent, and language plugins that load only for their filetypes.
-- General-purpose tools are in legacy-tools.lua.
---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
    {
        -- TODO can this be substituted with something that `mini.nvim` offers, or Treesitter text objects?
        "dewyze/vim-ruby-block-helpers",
        ft = { "ruby" },
    },
    { "vim-scripts/VimClojure", lazy = true },
    { "vim-scripts/groovyindent-unix", lazy = true },
    { "vim-scripts/mako.vim", lazy = true },
    { "chase/vim-ansible-yaml", ft = { "ansible" } },
    { "cosmicbuffalo/vim-bats", ft = { "bash" } },
    { "elubow/cql-vim", lazy = true }, -- Cassandra syntax highlighting; can this be replaced with Treesitter?
    { "guns/vim-clojure-highlight", ft = { "clojure" } },
    { "guns/vim-clojure-static", ft = { "clojure" } },
    { "guns/vim-sexp", ft = { "clojure" } },
    { "tpope/vim-dispatch", ft = { "clojure" } },
    { "tpope/vim-fireplace", ft = { "clojure" } },
    { "tpope/vim-salve", ft = { "clojure" } },
    { "tpope/vim-sexp-mappings-for-regular-people", ft = { "clojure" } },
    { "kchmck/vim-coffee-script", ft = { "coffee" } },
    { "elixir-lang/vim-elixir", ft = { "elixir" } },
    {
        "fatih/vim-go",
        ft = { "go" },
        build = ":GoInstallBinaries",
        init = function()
            -- Disable features that we have other plugins for
            vim.g.go_def_mapping_enabled = 0 -- Let nvim-lspconfig handle gd
            vim.g.go_doc_keywordprg_enabled = 0 -- Let nvim-lspconfig handle K
            vim.g.go_fmt_autosave = 0 -- Let conform.nvim handle formatting
            vim.g.go_imports_autosave = 0 -- Let conform.nvim handle imports
            vim.g.go_code_completion_enabled = 0 -- Let blink.cmp handle completion
            -- Keep useful vim-go features like :GoCoverage, :GoTest, etc.
            vim.g.go_highlight_types = 1
            vim.g.go_highlight_fields = 1
            vim.g.go_highlight_functions = 1
            vim.g.go_highlight_function_calls = 1
        end,
    },
    { "jparise/vim-graphql", ft = { "graphql" } }, -- TODO can this be deprecated for Treesitter?
    { "akhaku/vim-java-unused-imports", ft = { "java" } },
    { "pangloss/vim-javascript", ft = { "javascript", "jsx" } },
    { "google/vim-jsonnet", ft = { "jsonnet" } },
    { "mxw/vim-jsx", ft = { "jsx" } },
    { "Glench/Vim-Jinja2-Syntax", ft = { "jinja" } },
    { "aklt/plantuml-syntax", ft = { "plantuml" } },
    { "tpope/vim-markdown", ft = { "markdown" } },
    { "rodjek/vim-puppet", ft = { "puppet" } },
    { "tpope/vim-cucumber", ft = { "ruby" } },
    {
        "tpope/vim-rails",
        lazy = false,
        priority = 10,
        ft = { "ruby" },
        init = function()
            vim.g["rails_projections"] = {
                ["script/*.rb"] = {
                    test = "spec/script/{}_spec.rb",
                },
                ["spec/script/*_spec.rb"] = {
                    alternate = "script/{}.rb",
                },
                ["app/lib/*.rb"] = {
                    test = "spec/lib/{}_spec.rb",
                },
                ["lib/tasks/*.rake"] = {
                    test = "spec/lib/tasks/{}_rake_spec.rb",
                },
            }
        end,
    },
    { "rust-lang/rust.vim", ft = { "rust" } },
    { "jergason/scala.vim", ft = { "scala" } },
    { "derekwyatt/vim-scala", ft = { "scala" } },
    { "hashivim/vim-terraform", ft = { "terraform" } },
    { "lmeijvogel/vim-yaml-helper", ft = { "yaml" } },
}
