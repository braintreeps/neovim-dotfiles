-- UI notifications: noice (command line and message popups) and nvim-notify (toast notifications).
-- Both are disabled here; enable them in the personal overlay.
return {
    {
        "folke/noice.nvim",
        enabled = false, -- turn this on in your neovim-dotfiles-personal to enable fancy command and search lines, plus command visualization in the lualine
        dependencies = { "rcarriga/nvim-notify" },
        event = "VeryLazy",
        opts = {
            presets = {
                bottom_search = false,
                command_palette = true,
                long_message_to_split = true,
                inc_rename = true,
                lsp_doc_border = true,
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        enabled = false, -- turn this on in your neovim-dotfiles-personal to enable toast-like notifications in the top right corner of neovim
        keys = {
            {
                "<leader>un",
                function()
                    require("notify").dismiss({ silent = true, pending = true })
                end,
                desc = "Dismiss All Notifications",
            },
            {
                "<leader>uh",
                function()
                    require("telescope").extensions.notify.notify()
                end,
                desc = "Notification History",
            },
        },
        opts = {
            stages = "static",
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        },
    },
}
