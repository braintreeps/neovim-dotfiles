vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd([[checkhealth vim.lsp]])
end, { desc = "[LSP] Check vim.lsp configurations" })

vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd("tabnew " .. vim.lsp.log.get_filename())
end, { desc = "[LSP] Open up Lsp logs" })

-- Redirect vim-plug commands to Lazy equivalents
for plug_cmd, lazy_cmd in pairs({
    Plug = "",
    PlugInstall = "install",
    PlugUpdate = "update",
    PlugUpgrade = "update",
    PlugDiff = "log",
    PlugClean = "clean",
    PlugStatus = "",
    PlugSnapshot = "profile",
}) do
    vim.api.nvim_create_user_command(plug_cmd, function()
        vim.notify("Lazy has replaced Plug. Executing :Lazy " .. lazy_cmd, vim.log.levels.WARN)
        vim.defer_fn(function()
            vim.cmd("Lazy " .. lazy_cmd)
        end, 2000)
    end, { desc = "Redirect " .. plug_cmd .. " to Lazy " .. lazy_cmd })
end
