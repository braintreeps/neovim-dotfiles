local Utils = require("config.utils")
local lockfiles = require("config.utils.lockfiles")
local lsp_contract = require("config.utils.lsp_contract")

local M = {}

local health = vim.health
local config_dir = vim.fn.stdpath("config")

local function check_version()
    health.start("Neovim version")
    local v = vim.version()
    local version = ("%d.%d.%d"):format(v.major, v.minor, v.patch)
    if vim.fn.has("nvim-0.11") == 1 then
        health.ok("Neovim " .. version)
        return true
    end
    health.error("Neovim " .. version .. " is too old; 0.11 or newer is required", {
        "Upgrade Neovim, for example from https://github.com/neovim/neovim/releases",
    })
    return false
end

local function check_executables()
    health.start("Executables")
    if vim.fn.executable("git") == 1 then
        health.ok("git found")
    else
        health.error("git not found", { "Install git; lazy.nvim is bootstrapped from it" })
    end

    local _, found = Utils.treesitter.check()
    local names = vim.tbl_keys(found)
    table.sort(names)
    for _, name in ipairs(names) do
        if found[name] then
            health.ok(name .. " found")
        else
            health.error(
                name .. " not found",
                { "Install it; Mason and nvim-treesitter need it to fetch and build tools" }
            )
        end
    end

    local optional = {
        { "rg", "Telescope live grep" },
        { "make", "building telescope-fzf-native" },
        { "npm", "Mason npm packages (ts_ls, prettier)" },
        { "gem", "ruby-lsp and rubocop through gem_install" },
        { "mise", "Java runtimes in lua/plugins/java.lua" },
        { "terraform", "terraform formatting" },
        { "sqlfluff", "SQL formatting" },
        { "gh", "GitHub links in lua/config/keymaps.lua" },
        { "lazygit", "the Lazygit integration" },
    }
    for _, tool in ipairs(optional) do
        if vim.fn.executable(tool[1]) == 1 then
            health.ok(tool[1] .. " found")
        else
            health.info(("%s not found (optional, needed for %s)"):format(tool[1], tool[2]))
        end
    end
end

local function check_lsp_contract()
    health.start("LSP contract (lua/plugins/lsp.lua)")
    local ok, opts = pcall(lsp_contract.plugin_opts, "neovim/nvim-lspconfig")
    if not ok then
        return health.error("Could not load lua/plugins/lsp.lua: " .. tostring(opts), { "Fix the error above" })
    end
    if not opts then
        return health.error("nvim-lspconfig spec not found in lua/plugins/lsp.lua")
    end
    local problems = lsp_contract.validate(opts.server_defs or {}, opts.filetype_tooling or {})
    if #problems == 0 then
        return health.ok("server_defs and filetype_tooling agree")
    end
    for _, problem in ipairs(problems) do
        health.error(problem, { "Add the server to server_defs or correct the name in filetype_tooling" })
    end
end

local function owned_by_this_repo(name, declared)
    local loaded, source = pcall(require, "super_lazy.source")
    if loaded then
        local repo = source.get_plugin_source(name)
        if repo then
            return vim.fn.resolve(repo) == vim.fn.resolve(config_dir)
        end
    end
    return declared[name] == true
end

local function check_lockfiles()
    health.start("Lockfiles")

    local lazy_lock, lazy_err = lockfiles.read_json(config_dir .. "/lazy-lock.json")
    if not lazy_lock then
        health.error("lazy-lock.json is " .. lazy_err, { "Restore it from git" })
    else
        health.ok("lazy-lock.json parses")
        local loaded, lazy_config = pcall(require, "lazy.core.config")
        if loaded then
            local declared = lockfiles.declared_plugins(config_dir .. "/lua/plugins")
            local unlocked = {}
            for name in pairs(lazy_config.plugins) do
                if owned_by_this_repo(name, declared) and lazy_lock[name] == nil then
                    unlocked[#unlocked + 1] = name
                end
            end
            table.sort(unlocked)
            if #unlocked == 0 then
                health.ok("Every plugin owned by this repo has a lazy-lock.json entry")
            else
                health.warn("Not in lazy-lock.json: " .. table.concat(unlocked, ", "), {
                    "Record them with :Lazy update <name>, or remove them if they are no longer declared",
                })
            end
        else
            health.info("lazy.nvim is not loaded, so plugins were not compared with lazy-lock.json")
        end
    end

    local mason_lock, mason_err = lockfiles.read_json(config_dir .. "/mason-lock.json")
    if not mason_lock then
        return health.error("mason-lock.json is " .. mason_err, { "Restore it from git" })
    end
    health.ok("mason-lock.json parses")

    local ok, mason_lock_opts = pcall(lsp_contract.plugin_opts, "cosmicbuffalo/mason-lock.nvim")
    local locked = ok and mason_lock_opts and mason_lock_opts.locked_packages or {}
    local missing = lockfiles.unlocked_packages(locked, mason_lock)
    if #missing == 0 then
        health.ok("Every locked_packages entry is in mason-lock.json")
    else
        health.warn("Listed in locked_packages but missing from mason-lock.json: " .. table.concat(missing, ", "), {
            "Install each with :Mason so mason-lock.nvim records it, or remove it from locked_packages in lua/plugins/lsp.lua",
        })
    end
end

local function check_treesitter()
    health.start("Treesitter parsers")
    if vim.fn.isdirectory(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter") == 0 then
        return health.info("nvim-treesitter is not installed; parser check skipped")
    end

    local parser_dir = vim.fn.stdpath("data") .. "/site/parser/"
    local missing = {}
    for _, lang in ipairs(Utils.treesitter.ensure_installed) do
        if not vim.uv.fs_stat(parser_dir .. lang .. ".so") then
            missing[#missing + 1] = lang
        end
    end
    if #missing == 0 then
        return health.ok(("All %d parsers in ensure_installed are present"):format(#Utils.treesitter.ensure_installed))
    end
    health.warn("Missing parsers: " .. table.concat(missing, ", "), {
        "Run :TSInstall " .. table.concat(missing, " "),
    })
end

local function check_personal()
    health.start("Personal overlay (lua/personal)")
    local hooks = {
        { "lua/personal/options.lua", "personal.options" },
        { "lua/personal/plugins", "personal.plugins" },
        { "lua/personal/init.lua", "personal.init" },
    }
    local found = false
    for _, hook in ipairs(hooks) do
        local path = config_dir .. "/" .. hook[1]
        if vim.uv.fs_stat(path) then
            found = true
            health.ok(hook[1] .. " present")
            if hook[2] ~= "personal.plugins" and package.loaded[hook[2]] == nil then
                health.warn(hook[2] .. " exists but was not loaded", { "Check :messages for a startup error" })
            end
        end
    end
    if not found then
        health.info("No personal overlay found; it is optional")
    end
end

local function check_clipboard()
    health.start("Clipboard")
    if vim.g.clipboard == "osc52" then
        health.ok("Using OSC 52 (set in lua/config/options.lua)")
        health.info("Yanks reach the system clipboard only if the terminal supports OSC 52 writes")
    elseif vim.g.clipboard then
        health.ok("Using a custom clipboard provider")
    else
        health.info("No clipboard override; Neovim uses its default provider (see :checkhealth vim.provider)")
    end
end

local function check_font()
    health.start("Nerd Font")
    health.info("Icons need a Nerd Font in the terminal; if U+E0B0 and U+F07B render as boxes, change the font")
end

function M.check()
    if not check_version() then
        return
    end
    check_executables()
    check_lsp_contract()
    check_lockfiles()
    check_treesitter()
    check_personal()
    check_clipboard()
    check_font()
end

return M
