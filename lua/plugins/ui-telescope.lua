-- Telescope pickers, keymaps, and extensions. Picker helpers live in config.utils.telescope.
local Utils = require("config.utils")

return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
            {
                "nvim-mini/mini.bufremove",
                keys = {
                    {
                        "<leader>bd",
                        function()
                            local bd = require("mini.bufremove").delete
                            if vim.bo.modified then
                                local choice = vim.fn.confirm(
                                    ("Save changes to %q?"):format(vim.fn.bufname()),
                                    "&Yes\n&No\n&Cancel"
                                )
                                if choice == 1 then -- Yes
                                    vim.cmd.write()
                                    bd(0)
                                elseif choice == 2 then -- No
                                    bd(0, true)
                                end
                            else
                                bd(0)
                            end
                        end,
                        desc = "Delete Buffer",
                    },
                    -- stylua: ignore
                    { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
                },
            },
        },
        -- stylua: ignore
        keys = {
            -- Misc keymaps
            { "<Leader><Leader>", "<cmd>Telescope find_files<CR>",                desc = "Find files" },
            { "<C-p>",            function() Utils.telescope.find_files_from_project_git_root() end,  desc = "Find (git) files" },
            { "<Leader>be",       function() Utils.telescope.open_buffer_explorer() end,            desc = "Buffer Explorer" },
            { "<Leader>gw",       "<cmd>Telescope grep_string<CR>",               desc = "Grep word in cursor" },
            Utils.colors.SwitchColorschemeKeyMap,
            -- "find" keymaps
            { "<Leader>ff",       function() Utils.telescope.find_files_from_project_git_root() end,  desc = "Find (git) files" },
            { "<Leader>fg",       "<cmd>Telescope live_grep<CR>",                 desc = "Find (grep)" },
            { "<Leader>fb",       function() Utils.telescope.open_buffer_explorer() end,            desc = "Find Buffers" },
            { "<Leader>fr",       "<cmd>Telescope oldfiles<CR>",                  desc = "Find Recent" },
            { "<Leader>fmp",      "<cmd>Telescope man_pages<CR>",                 desc = "Find man pages" },
            { "<Leader>fh",       "<cmd>Telescope help_tags<CR>",                 desc = "Find help tags" },
            { "<Leader>fm",       "<cmd>Telescope marks<CR>",                     desc = "Find marks" },
            { "<Leader>fd",       "<cmd>Telescope diagnostics bufnr=0<CR>",       desc = "Document Diagnostics" },
            { "<Leader>fD",       "<cmd>Telescope diagnostics<CR>",               desc = "Workspace Diagnostics" },
            { "<Leader>fp",       function() Utils.telescope.open_plugin_explorer() end,            desc = "Find Plugin File" },
            -- "search" keymaps
            { "<Leader>sk",       "<cmd>Telescope keymaps<CR>",                   desc = "Keymaps" },
            { '<Leader>s"',       "<cmd>Telescope registers<CR>",                 desc = "Registers" },
            { "<Leader>sa",       "<cmd>Telescope autocommands<CR>",              desc = "Auto commands" },
            { "<Leader>sg",       "<cmd>Telescope live_grep<CR>",                 desc = "Grep" },
            { "<Leader>sb",       "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Buffer Fuzzy Find" },
            { "<Leader>sh",       "<cmd>Telescope help_tags<CR>",                 desc = "Help Pages" },
            { "<Leader>sC",       "<cmd>Telescope commands<CR>",                  desc = "Commands" },
            { "<Leader>sc",       "<cmd>Telescope command_history<CR>",           desc = "Command History" },
            { "<Leader>so",       "<cmd>Telescope vim_options<CR>",               desc = "Options" },
            { "<Leader>sw",       "<cmd>Telescope grep_string<CR>",               desc = "Word under cursor" },
            { "<Leader>sw",       "<cmd>Telescope grep_string<CR>",               mode = "v",                        desc = "Selection" },
            { "<Leader>sr",       "<cmd>Telescope resume<CR>",                    desc = "Resume" },
        },
        opts = {
            defaults = {
                file_ignore_patterns = {
                    "node_modules/",
                    "%.git/refs/",
                    "%.git/logs/",
                    "%.git/objects/",
                    "%.git/hooks/.*%.sample$",
                    "%.git/rr%-cache/",
                    "%.git/packed%-refs.*",
                    "%.git/.*HEAD$",
                    "tmp/cache/",
                    "sorbet/rbi/annotations/",
                    "sorbet/rbi/dsl/",
                    "sorbet/rbi/gems/",
                    "%.class$",
                },
                sorting_strategy = "ascending",
                layout_config = {
                    prompt_position = "top",
                    horizontal = {
                        width = {
                            padding = function(_self, max_columns, _max_lines)
                                -- On small terminals it's not worth spending
                                -- space on the context of behind the picker, so
                                -- make it full width.
                                --
                                -- But on larger terminals, it's desirable to
                                -- show context so that people don't lose track
                                -- of where they were. For example, it makes it
                                -- easier to see what pane you trigger the
                                -- picker from and treat the picker as a modal.
                                -- Otherwise with the picker's split list/preview
                                -- it's easy for the picker (e.g., when
                                -- triggered from a right pane) to feel like
                                -- you've been moved to the left pane, and then
                                -- when a file/buffer is selected it's visually
                                -- jarring/confusing when you end back up in the
                                -- right pane.
                                if max_columns <= 80 then
                                    return 0
                                else
                                    return math.ceil(max_columns * 0.04 + 2)
                                end
                            end,
                        },
                        height = {
                            padding = function(_self, _max_columns, max_lines)
                                -- On small terminals it's not worth spending
                                -- space on the context of behind the picker, so
                                -- make it full height.
                                --
                                -- But on larger terminals, it's desirable to
                                -- show context so that people don't lose track
                                -- of where they were.
                                if max_lines <= 30 then
                                    return 0
                                else
                                    return math.ceil(max_lines * 0.03 + 2)
                                end
                            end,
                        },
                        preview_width = 0.5,
                    },
                },
                mappings = {
                    i = {
                        ["<C-I>"] = Utils.telescope.toggle_no_ignore,
                    },
                    n = {
                        ["<C-I>"] = Utils.telescope.toggle_no_ignore,
                    },
                },
            },
            pickers = {
                live_grep = {
                    additional_args = function(_)
                        return { "--hidden" }
                    end,
                    mappings = {
                        i = {
                            ["<C-e>"] = function(prompt_bufnr)
                                Utils.telescope.scope_to_dir(prompt_bufnr, require("telescope.builtin").live_grep)
                            end,
                        },
                    },
                },
                find_files = {
                    hidden = true,
                    mappings = {
                        i = {
                            ["<C-e>"] = function(prompt_bufnr)
                                Utils.telescope.scope_to_dir(prompt_bufnr, require("telescope.builtin").find_files)
                            end,
                        },
                    },
                },
                git_files = {
                    show_untracked = true,
                    hidden = true,
                    mappings = {
                        i = {
                            ["<C-e>"] = function(prompt_bufnr)
                                Utils.telescope.scope_to_dir(prompt_bufnr, require("telescope.builtin").find_files) -- intentional move to find_files to respect cwd option
                            end,
                        },
                    },
                },
                buffers = {
                    initial_mode = "normal",
                },
            },
        },
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)

            telescope.load_extension("fzf")
            telescope.load_extension("ui-select")
            telescope.load_extension("file_browser")
        end,
    },
}
