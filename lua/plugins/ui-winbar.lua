-- Winbar: heirline with dropbar breadcrumbs. Winbar components are built in config.heirline.
local Utils = require("config.utils")

return {
    {
        "rebelot/heirline.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lualine/lualine.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                "Bekaboo/dropbar.nvim",
                lazy = false,
                opts = {
                    menu = {
                        -- turn this off to disable dynamic preview on menu movement
                        -- dynamic previews can also be toggled per source (see below)
                        -- preview = false,
                    },
                    bar = {
                        -- turn off the automatic attachment behavior since it'll be
                        -- handled by the component in heirline
                        enable = false,
                        sources = function(buf, _)
                            local utils = require("dropbar.utils")
                            local sources = require("dropbar.sources")
                            if vim.bo[buf].ft == "oil" then
                                return {
                                    sources.path,
                                }
                            end
                            if vim.bo[buf].ft == "markdown" then
                                return {
                                    sources.path,
                                    sources.markdown,
                                }
                            end
                            if vim.bo[buf].buftype == "terminal" then
                                return {
                                    sources.terminal,
                                }
                            end
                            return {
                                sources.path,
                                utils.source.fallback({
                                    sources.lsp,
                                    -- sources.treesitter,
                                }),
                            }
                        end,
                    },
                    sources = {
                        path = {
                            -- Preview is turned off by default for the path source
                            preview = false,
                            -- This customizes the path source for oil buffers
                            -- oil buffers will show the path relative to the
                            -- git root, if available
                            relative_to = function(buf, win)
                                local bufname = vim.api.nvim_buf_get_name(buf)
                                if vim.startswith(bufname, "oil://") then
                                    local full_path = bufname:gsub("^%S+://", "", 1)
                                    local git_root =
                                        vim.fs.find(".git", { upward = true, path = full_path, type = "directory" })
                                    if git_root and #git_root > 0 then
                                        local git_dir = vim.fs.dirname(git_root[1])
                                        return vim.fs.dirname(git_dir)
                                    end
                                end

                                local ok, cwd = pcall(vim.fn.getcwd, win)
                                return ok and cwd or vim.fn.getcwd()
                            end,
                        },
                        lsp = {
                            valid_symbols = {
                                -- Customize this list to control what can show
                                -- up as breadcrumbs in the dropbar winbar
                                -- for lsp source
                                "Module",
                                "Namespace",
                                "Class",
                                "Method",
                                "Function",
                                "Constructor",
                                "Array",
                                "Object",
                            },
                        },
                        treesitter = {
                            valid_types = {
                                -- TODO: This filtering doesn't actually work
                                -- Customize this list to control what can show
                                -- up as breadcrumbs in the dropbar winbar for
                                -- treesitter source
                                "class",
                                "constructor",
                                "do_statement",
                                "function",
                                "if_statement",
                                "method",
                                "namespace",
                                "table",
                                "type",
                                "object",
                            },
                        },
                    },
                    icons = {
                        -- Icons for dropbar can be customized here
                        ui = {
                            bar = {
                                -- separator = " > ",
                                separator = "  ",
                                extends = "…",
                            },
                            menu = {
                                -- indicator = "> ",
                                indicator = " ",
                                separator = " ",
                            },
                        },
                    },
                },
                keys = {
                    {
                        "<leader>bo",
                        function()
                            require("dropbar.api").pick()
                        end,
                        desc = "Drop[b]ar - [O]pen Picker",
                    },
                },
            },
        },
        opts = {
            winbar_disabled_buftypes = { "nofile", "prompt", "help", "quickfix", "terminal" },
            winbar_disabled_filetypes = {
                "^git.*",
                "fugitive",
                "Trouble",
                "dashboard",
                "neo-tree",
                "which-key",
                "lazygit",
            },
            -- toggle this to remove the mode wapper on active winbar
            enable_mode_wrapper = true,
            -- customize mode color assignments here
            -- (settings for inkline or tokyonight are automatically applied)
            mode_colors = Utils.colors.get_mode_colors,
            -- customize heirline color mappings to colorscheme highlights here
            -- (settings for inkline or tokyonight are automatically applied)
            color_highlight_mappings = Utils.colors.get_highlight_mappings,
            inactive_color = "#1e2124",
        },
        config = function(_, opts)
            local heirline_config = require("config.heirline")
            local setup_colors = function()
                return Utils.colors.setup_heirline_colors(opts)
            end
            require("heirline").load_colors(setup_colors)

            vim.api.nvim_create_augroup("Heirline", { clear = true })
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    local utils = require("heirline.utils")
                    utils.on_colorscheme(setup_colors)
                end,
                group = "Heirline",
            })

            require("heirline").setup({
                winbar = heirline_config.build_winbar(opts),
                opts = heirline_config.build_opts(opts),
            })
        end,
        keys = {
            {
                "<leader>uW",
                function()
                    require("config.heirline").toggle_winbar()
                end,
                desc = "Toggle [U]I [W]inbar",
            },
        },
    },
}
