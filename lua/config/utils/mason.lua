local M = {}

---@param tools string[]
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

---@param servers string[]
---@param lsp_opts table
---@param ft string filetype that requested these servers (for error messages)
function M.install_servers(servers, lsp_opts, ft)
    local mr = require("mason-registry")

    mr.refresh(function()
        -- Every server named in filetype_tooling MUST be defined in server_defs.
        -- A silent fallback to {} would let typos through (e.g. filetype_tooling
        -- referencing "yaml-language-server" when the def key is "yamlls"), which
        -- previously caused per-server config to be silently dropped.
        local function process_server(server)
            local server_config = lsp_opts.server_defs[server]
            if not server_config then
                vim.schedule(function()
                    vim.notify(
                        string.format(
                            "LSP server '%s' (requested by filetype '%s') is not defined in `server_defs`",
                            server,
                            ft or "?"
                        ),
                        vim.log.levels.ERROR,
                        { title = "lsp-contract" }
                    )
                end)
                return
            end

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

        for _, server in ipairs(servers) do
            process_server(server)
        end
    end)
end

return M
