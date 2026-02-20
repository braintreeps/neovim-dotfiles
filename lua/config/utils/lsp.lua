local M = {}

-- Tracks what filetypes we've completed on-demand LSP setup for
local processed_filetypes = {}

local function install_mason_tools(tools)
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

local function install_mason_servers(servers, lsp_opts)
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

-- gems is a table mapping gem_name -> lsp_server_name
local function install_gems(gems, lsp_opts)
    local gem_install = require("gem_install")

    local configure_gem_server = function(server)
        local server_config = lsp_opts.servers[server] or {}
        if lsp_opts.capabilities then
            server_config = vim.tbl_deep_extend("force", { capabilities = lsp_opts.capabilities }, server_config)
        end
        vim.lsp.config(server, server_config)
        pcall(vim.lsp.enable, server)
    end

    for gem_name, server in pairs(gems) do
        -- Check if the executable is already available before trying gem install
        if vim.fn.executable(gem_name) == 1 then
            -- Server is already available, so configure and enable it
            configure_gem_server(server)
        else
            -- Need to install the gem first
            gem_install.install(gem_name, function(installed, _, err)
                if installed then
                    configure_gem_server(server)
                end
            end)
        end
    end
end

function M.ensure_for_filetype(ft, lsp_opts)
    if processed_filetypes[ft] then
        return
    end
    processed_filetypes[ft] = true

    local config = lsp_opts.filetype_config[ft]
    if not config then
        return
    end

    vim.defer_fn(function()
        -- Install mason tools
        if config.tools and #config.tools > 0 then
            install_mason_tools(config.tools)
        end

        -- Install mason LSP servers
        if config.servers then
            install_mason_servers(config.servers, lsp_opts)
        end

        -- Install gems via gem_install.nvim (gems is a map of gem_name -> lsp_server)
        if config.gems then
            install_gems(config.gems, lsp_opts)
        end
    end, 100)
end

-- stylua: ignore
local function on_attach(_client, bufnr, opts)
    --- Sets keymaps with default options
    --- @param modes string|string[]
    --- @param lhs string
    --- @param rhs string|function
    --- @param set_opts? table
    local function set(modes, lhs, rhs, set_opts)
        -- passing something other than a string will disable the keymap
        if type(lhs) ~= "string" then
            return
        end
        local defaults = { noremap = true, silent = true, buffer = bufnr }
        local local_opts = vim.tbl_deep_extend("force", defaults, set_opts or {})

        vim.keymap.set(modes, lhs, rhs, local_opts)
    end
    -- clean up default neovim LSP keymaps
    pcall(vim.keymap.del, "n", "gra")
    pcall(vim.keymap.del, "x", "gra")
    pcall(vim.keymap.del, "n", "gri")
    pcall(vim.keymap.del, "n", "grn")
    pcall(vim.keymap.del, "n", "grr")

    -- Navigation
    set(
        "n",
        opts.keymap.go_to_declaration,
        vim.lsp.buf.declaration,
        { desc = "LSP: [g]o to [D]eclaration" }
    )
    set(
        "n",
        opts.keymap.go_to_definition,
        vim.lsp.buf.definition,
        { desc = "LSP: [g]o to [d]efinition" }
    )
    set(
        "n",
        opts.keymap.go_to_implementation,
        vim.lsp.buf.implementation,
        { desc = "LSP: [g]o to [i]mplementation" }
    )
    set(
        "n",
        opts.keymap.go_to_references,
        vim.lsp.buf.references,
        { desc = "LSP: [g]o to [r]eferences" }
    )

    -- Information
    set(
        "n",
        opts.keymap.hover,
        function() vim.lsp.buf.hover({ border = "rounded" }) end,
        { desc = "LSP: Hover" }
    )
    set(
        { "n", "i" },
        opts.keymap.signature_help,
        function() vim.lsp.buf.signature_help({ border = "rounded" }) end,
        { desc = "LSP: Signature help" }
    )
    set(
        "n",
        opts.keymap.toggle_inlay_hints,
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
        { desc = "LSP: Toggle inlay hints" }
    )
    set(
        "n",
        opts.keymap.document_symbols,
        vim.lsp.buf.document_symbol,
        { desc = "LSP: [d]ocument [s]ymbol" }
    )
    set(
        "n",
        opts.keymap.lsp_info,
        '<cmd>LspInfo<cr>',
        { desc = "LSP: server [i]nfo" }
    )
    set(
        "n",
        opts.keymap.type_definition,
        vim.lsp.buf.type_definition,
        { desc = "LSP: type [D]efinition" }
    )
    set(
        "n",
        opts.keymap.lsp_code_format,
        vim.lsp.buf.format,
        { desc = "LSP: [c]ode [f]ormat" }
    )
    -- Diagnostics
    set(
        "n",
        opts.keymap.jump_to_prev_diagnostic,
        function() vim.diagnostic.jump({ count = -1, float = true }) end,
        { desc = "LSP: jump to previous [d]iagnostic" }
    )
    set(
        "n",
        opts.keymap.jump_to_next_diagnostic,
        function() vim.diagnostic.jump({ count = 1, float = true }) end,
        { desc = "LSP: jump to next [d]iagnostic" }
    )
    set(
        "n",
        opts.keymap.diagnostic_explain,
        vim.diagnostic.open_float,
        { desc = "LSP: [d]iagnostic [e]xplain" }
    )
    set(
        "n",
        opts.keymap.diagnostics_to_quickfix,
        vim.diagnostic.setloclist,
        { desc = "LSP: add buffer diagnostics to [q]uickfix" }
    )
    set(
        "n",
        opts.keymap.toggle_diagnostics,
        function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
        { desc = "[d]iagnostics [t]oggle" }
    )

    -- Refactoring
    set(
        "n",
        opts.keymap.lsp_rename,
        vim.lsp.buf.rename,
        { desc = "LSP: [r]ename" }
    )
    set(
        "n",
        opts.keymap.lsp_code_action,
        vim.lsp.buf.code_action,
        { desc = "LSP: [c]ode [a]ction" }
    )

    -- Workspaces
    set(
        "n",
        opts.keymap.workspace_add_folder,
        vim.lsp.buf.add_workspace_folder,
        { desc = "LSP: [w]orkspace [a]dd folder" }
    )
    set(
        "n",
        opts.keymap.workspace_remove_folder,
        vim.lsp.buf.remove_workspace_folder,
        { desc = "LSP: [w]orkspace [r]emove folder" }
    )
    set(
        "n",
        opts.keymap.workspace_list_folders,
        function()
            vim.print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        { desc = "LSP: [w]orkspace [l]ist folders" }
    )
    set(
        "n",
        opts.keymap.workspace_symbols,
        vim.lsp.buf.workspace_symbol,
        { desc = "LSP: [w]orkspace [s]ymbol" }
    )
end

function M.setup_on_attach(opts)
    return vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local buffer = args.buf ---@type number
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client then
                on_attach(client, buffer, opts)
            end
        end,
    })
end

return M
