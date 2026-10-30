-- Statusline: lualine and its custom components. The winbar is drawn by heirline (see ui-winbar.lua).
return {
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = {
            {
                "nvim-tree/nvim-web-devicons",
                opts = {
                    override_by_filename = {
                        ["rakefile"] = {
                            icon = "",
                            color = "#ff4f3f",
                            cterm_color = "52",
                            name = "Rakefile",
                        },
                        ["Gemfile"] = {
                            icon = "",
                            color = "#ff4f3f",
                            cterm_color = "52",
                            name = "Rakefile",
                        },
                    },
                    override_by_extension = {
                        ["config.ru"] = {
                            icon = "",
                            color = "#ff4f3f",
                            cterm_color = "52",
                            name = "ConfigRu",
                        },
                        ["rb"] = {
                            icon = "",
                            color = "#ff4f3f",
                            cterm_color = "52",
                            name = "Rb",
                        },
                    },
                },
            },
        },
        opts = function()
            -- NOTE: This isn't personalizable without duplicating the entire function
            local utils = require("lualine.utils.utils")
            local highlight = require("lualine.highlight")
            local conf = require("lualine").get_config()
            local diagnostics_message = require("lualine.component"):extend()

            diagnostics_message.default = {
                colors = {
                    error = utils.extract_color_from_hllist({ "fg", "sp" }, { "DiagnosticError" }, "#e32636"),
                    warning = utils.extract_color_from_hllist({ "fg", "sp" }, { "DiagnosticWarn" }, "#ffa500"),
                    info = utils.extract_color_from_hllist({ "fg", "sp" }, { "DiagnosticInfo" }, "#ffffff"),
                    hint = utils.extract_color_from_hllist({ "fg", "sp" }, { "DiagnosticHint" }, "#273faf"),
                },
            }
            function diagnostics_message:init(options)
                diagnostics_message.super:init(options)
                self.options.colors =
                    vim.tbl_extend("force", diagnostics_message.default.colors, self.options.colors or {})
                self.highlights = { error = "", warn = "", info = "", hint = "" }
                self.highlights.error = highlight.create_component_highlight_group(
                    { fg = self.options.colors.error },
                    "diagnostics_message_error",
                    self.options
                )
                self.highlights.warn = highlight.create_component_highlight_group(
                    { fg = self.options.colors.warn },
                    "diagnostics_message_warn",
                    self.options
                )
                self.highlights.info = highlight.create_component_highlight_group(
                    { fg = self.options.colors.info },
                    "diagnostics_message_info",
                    self.options
                )
                self.highlights.hint = highlight.create_component_highlight_group(
                    { fg = self.options.colors.hint },
                    "diagnostics_message_hint",
                    self.options
                )
            end

            function diagnostics_message:update_status(_is_focused)
                local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
                local diagnostics = vim.diagnostic.get(0, { lnum = r - 1 })
                if #diagnostics > 0 then
                    table.sort(diagnostics, function(a, b)
                        if a.col == b.col then
                            return a.severity < b.severity
                        else
                            return a.col < b.col
                        end
                    end)

                    local icons = { "󰅚 ", "󰀪 ", "󰋽 ", "󰌶 " }
                    local hl =
                        { self.highlights.error, self.highlights.warn, self.highlights.info, self.highlights.hint }

                    local messages = {}
                    for _, diag in ipairs(diagnostics) do
                        -- Take only the first line of multi-line diagnostic messages
                        local first_line = diag.message:match("^[^\r\n]*")
                        local msg = icons[diag.severity] .. (diag.col + 1) .. ": " .. first_line
                        table.insert(messages, msg)
                    end

                    -- Use the most severe diagnostic's highlight for the entire string
                    local most_severe = diagnostics[1]
                    return highlight.component_format_highlight(hl[most_severe.severity])
                        .. table.concat(messages, "  ")
                else
                    return ""
                end
            end
            local updater_component = {}
            local has_updater, updater = pcall(require, "updater")
            if has_updater then
                updater_component = {
                    function()
                        return updater.status.get_update_text("icon")
                    end,
                    cond = function()
                        return updater.status.has_updates()
                    end,
                    color = function()
                        local status = updater.status.get()
                        -- Different colors based on update type
                        if status.needs_update and status.has_plugin_updates then
                            return { fg = "#f7768e" } -- Red for both types
                        elseif status.needs_update then
                            return { fg = "#ff9e64" } -- Orange for dotfiles
                        else
                            return { fg = "#9ece6a" } -- Green for plugins only
                        end
                    end,
                    on_click = function()
                        updater.open()
                    end,
                }
            end

            local new_conf = vim.tbl_deep_extend("force", conf, {
                theme = "inkline",
                options = {
                    ignore_focus = { "neo-tree" },
                },
                sections = {
                    lualine_c = {
                        {
                            "filetype",
                            icon_only = true,
                            separator = { right = "" },
                            padding = { left = 1, right = 0 },
                        },
                        {
                            "filename",
                            path = 1,
                            separator = { left = "" },
                            padding = { left = 0 },
                        },
                        {
                            diagnostics_message,
                            colors = {
                                error = "#e32636",
                                warn = "#ffa500",
                            },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                local ok, noice = pcall(require, "noice")
                                if ok then
                                    return noice.api.status.command.get()
                                end
                                return ""
                            end,
                            cond = function()
                                local ok, noice = pcall(require, "noice")
                                return ok and noice.api.status.command.has()
                            end,
                            color = { fg = "#ff9e64" },
                        },
                        {
                            function()
                                local reg = vim.fn.reg_recording()
                                if reg == "" then
                                    return ""
                                else
                                    return "recording @" .. reg
                                end
                            end,
                            color = { fg = "yellow" },
                        },
                        {
                            "searchcount",
                            color = { fg = "cyan" },
                        },
                        updater_component,
                        -- "lsp_status"
                    },
                },
            })

            return new_conf
        end,
    },
}
