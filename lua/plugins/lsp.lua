-- LSP: configure the Language Server Protocol (LSP) client.
local Utils = require("config.utils")
local LazyFileEvents = Utils.lazy.LazyFileEvents

return {
    {
        "j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {
            notification = {
                window = {
                    winblend = 0, -- transparent background
                },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = LazyFileEvents,
        dependencies = {
            "mason.nvim",
            "j-hui/fidget.nvim",
            "saghen/blink.cmp",
            { "cosmicbuffalo/gem_install.nvim", opts = {} },
        },
        opts = {
            -- customize your keymap here, or disable a keymap by setting it to false
            keymap = {
                go_to_definition = "gd",
                go_to_declaration = "gD",
                go_to_references = "gr",
                go_to_implementation = "gi",
                jump_to_prev_diagnostic = "[d",
                jump_to_next_diagnostic = "]d",

                hover = "K",
                signature_help = "<C-k>",
                toggle_inlay_hints = "gh",

                diagnostic_explain = "<Leader>de",
                diagnostics_to_quickfix = "<leader>dq",
                toggle_diagnostics = "<Leader>dt",

                type_definition = "<Leader>cD",
                document_symbols = "<Leader>cs",
                lsp_rename = "<Leader>cr",
                lsp_code_action = "<Leader>ca",
                lsp_code_format = "<Leader>cf",
                lsp_info = "<Leader>ci",

                workspace_add_folder = "<Leader>cwa",
                workspace_remove_folder = "<Leader>cwr",
                workspace_list_folders = "<Leader>cwl",
                workspace_symbols = "<Leader>ws",
            },
            diagnostics = {
                severity_sort = true,
                float = { border = "rounded", source = "if_many" },
                underline = { severity = vim.diagnostic.severity.ERROR },
            },
            -- Language server specific configuration goes here
            -- the mason attribute informs the on-demand LSP setup
            -- of what the mason package name for a given LSP is
            -- (optional, will default to lsp server name key)
            servers = {
                lua_ls = {
                    mason = "lua-language-server",
                    settings = {
                        Lua = {
                            diagnostics = {
                                unusedLocalExclude = { "_*" }, -- Allow variables/arguments starting with '_' to be unused
                            },
                            workspace = {
                                checkThirdParty = false, -- Disable checking third-party libraries
                            },
                        },
                    },
                },
                gopls = {
                    -- mason = "gopls" (same as server name, so omitted)
                    settings = {
                        gopls = {
                            analyses = {
                                unusedparams = true,
                            },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },
                -- Ruby LSP servers are not managed by mason
                ruby_lsp = { mason = false },
                rubocop = { mason = false },
                bashls = { mason = "bash-language-server" },
            },
            -- Map filetypes to their required tooling
            -- Each entry can have: servers (LSP), tools (formatters/linters), gems (via gem_install)
            filetype_config = {
                lua = {
                    servers = { "lua_ls" },
                    tools = { "stylua" },
                },
                go = {
                    servers = { "gopls" },
                    tools = { "goimports", "gofumpt" },
                },
                sh = {
                    servers = { "bashls" },
                    tools = { "shfmt" },
                },
                bash = {
                    servers = { "bashls" },
                    tools = { "shfmt" },
                },
                ruby = {
                    -- Ruby LSP servers are installed via gems, not mason
                    -- Map gem name to the LSP server it provides
                    gems = {
                        ["ruby-lsp"] = "ruby_lsp",
                        ["rubocop"] = "rubocop",
                    },
                },
            },
        },
        config = vim.schedule_wrap(function(_, opts)
            local blink = require("blink.cmp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                blink.get_lsp_capabilities(),
                opts.capabilities or {}
            )

            -- Pass opts to the on_attach function to be able to customize keymaps
            Utils.lsp.setup_on_attach(opts)
            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            -- Add FileType autocmd for lazy tooling installation
            local lsp_opts = {
                servers = opts.servers,
                filetype_config = opts.filetype_config,
                capabilities = capabilities,
            }
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("lazy_lsp_tools", { clear = true }),
                callback = function(ev)
                    Utils.lsp.ensure_for_filetype(ev.match, lsp_opts)
                end,
            })

            -- Trigger for current buffer if it already has a filetype (e.g., opened from cmdline)
            local current_ft = vim.bo.filetype
            if current_ft and current_ft ~= "" then
                Utils.lsp.ensure_for_filetype(current_ft, lsp_opts)
            end
        end),
    },
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        dependencies = {
            {
                "cosmicbuffalo/mason-lock.nvim",
                opts = {
                    lockfile_scope = "locked_packages", -- only the packages below will be included in the lockfile
                    locked_packages = {
                        "stylua",
                        "shfmt",
                        "goimports",
                        "gofumpt",
                    },
                    silent = true,
                },
            },
        },
        keys = {
            { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
        },
        build = ":MasonUpdate",
        opts_extend = { "ensure_installed" },
        config = function(_, opts)
            require("mason").setup(opts)

            -- Patch mason's notify to use fidget instead of global vim.notify
            package.loaded["mason-core.notify"] = setmetatable({}, {
                __call = function(_, msg, level)
                    require("fidget.notification").notify(msg, level, {
                        group = "mason",
                        annote = "mason.nvim",
                    })
                end,
            })

            local mr = require("mason-registry")

            -- Keep success hook to trigger FileType after package install
            mr:on("package:install:success", function()
                vim.defer_fn(function()
                    -- trigger FileType event to possibly load this newly installed LSP server
                    require("lazy.core.handler.event").trigger({
                        event = "FileType",
                        buf = vim.api.nvim_get_current_buf(),
                    })
                end, 100)
            end)

            -- No eager mr.refresh() loop - all tools installed on-demand via Utils.lsp
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = "snacks.nvim", words = { "Snacks" } },
                { path = "lazy.nvim", words = { "LazyVim" } },
            },
        },
    },
}
