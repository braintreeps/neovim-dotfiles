local M = {}

function M.install_tools(tools)
    local mr = require("mason-registry")
    mr.refresh(function()
        for _, tool in ipairs(tools) do
            local ok, p = pcall(mr.get_package, tool)
            if ok and not p:is_installed() and not p:is_installing() then
                p:install()
            end
        end
    end)
end

function M.install_servers(servers, lsp_opts)
    local mr = require("mason-registry")

    mr.refresh(function()
        for _, server in ipairs(servers) do
            -- Apply server config before enabling, merging with capabilities
            local server_config = lsp_opts.servers[server] or {}
            if lsp_opts.capabilities then
                server_config = vim.tbl_deep_extend("force", { capabilities = lsp_opts.capabilities }, server_config)
            end

            vim.schedule(function()
                vim.lsp.config(server, server_config)
            end)

            -- Check if this server should be installed via a mason package
            -- mason = false means not installed via mason
            -- mason = nil means use server name as package name
            -- otherwise use the value as the package name
            local mason_pkg = server_config.mason
            if mason_pkg ~= false then
                local pkg_name = mason_pkg or server
                local ok, p = pcall(mr.get_package, pkg_name)
                if ok then
                    if not p:is_installed() and not p:is_installing() then
                        p:install()
                    end
                else
                    vim.schedule(function()
                        vim.notify(
                            string.format("Mason package '%s' not found for server '%s'", pkg_name, server),
                            vim.log.levels.ERROR
                        )
                    end)
                end
            end

            -- Enable the LSP server for this buffer
            vim.schedule(function()
                pcall(vim.lsp.enable, server)
            end)
        end
    end)
end

return M
