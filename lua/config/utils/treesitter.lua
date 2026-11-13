local M = {}

M._installed = nil ---@type table<string,boolean>?
M._queries = {} ---@type table<string,boolean>

M.ensure_installed = {
    "bash",
    "c",
    "cmake",
    "cue",
    "diff",
    "dockerfile",
    "embedded_template",
    "git_config",
    "git_rebase",
    "gitignore",
    "go",
    "groovy",
    "hcl",
    "html",
    "http",
    "java",
    "javascript",
    "jq",
    "json",
    "kotlin",
    "lua",
    "luadoc",
    "markdown",
    "markdown_inline",
    "properties",
    "proto",
    "puppet",
    "python",
    "ruby",
    "rust",
    "snowflake_sql",
    "sql",
    "ssh_config",
    "terraform",
    "toml",
    "typescript",
    "tsx",
    "vim",
    "vimdoc",
    "yaml",
}

-- Parsers that nvim-treesitter does not ship. `filetypes` lists the filetypes the parser takes
-- over from the default parser for that filetype.
---@type table<string, { install_info: table, filetypes: string[] }>
M.custom_parsers = {
    -- Snowflake SQL, a fork of the general SQL grammar nvim-treesitter uses for `sql`. It is a
    -- superset of that grammar, so it handles plain SQL too. The repo does not commit the
    -- generated parser, so installing it runs `tree-sitter generate` (about 20 seconds with
    -- tree-sitter 0.27). To bump it, change `revision` and run `:TSUpdate snowflake_sql`.
    snowflake_sql = {
        install_info = {
            url = "https://github.com/cosmicbuffalo/tree-sitter-snowflake-sql",
            revision = "f5ca85c9fd2b05cd1e2a9e37664859463a88db29", -- branch snowflake-grammar
            generate = true,
            generate_from_json = false, -- no src/grammar.json is committed either
            queries = "queries",
        },
        filetypes = { "sql" },
    },
}

-- Adds `custom_parsers` to nvim-treesitter's parser table. nvim-treesitter reloads that table, and
-- fires `User TSUpdate`, before every install and update, so the entries are re-added from that
-- event too. Also maps each parser's filetypes to it. Safe to call more than once.
function M.setup_custom_parsers()
    local function register()
        local parsers = require("nvim-treesitter.parsers")
        for lang, spec in pairs(M.custom_parsers) do
            parsers[lang] = { install_info = spec.install_info }
        end
    end
    vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("treesitter_custom_parsers", { clear = true }),
        pattern = "TSUpdate",
        callback = register,
    })
    register()
    for lang, spec in pairs(M.custom_parsers) do
        vim.treesitter.language.register(lang, spec.filetypes)
    end
end

---@param update boolean?
function M.get_installed(update)
    if update then
        M._installed, M._queries = {}, {}
        for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
            M._installed[lang] = true
        end
    end
    return M._installed or {}
end

---@param lang string
---@param query string
function M.have_query(lang, query)
    local key = lang .. ":" .. query
    if M._queries[key] == nil then
        M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
    end
    return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
    what = what or vim.api.nvim_get_current_buf()
    what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
    local lang = vim.treesitter.language.get_lang(what)
    if lang == nil or M.get_installed()[lang] == nil then
        return false
    end
    if query and not M.have_query(lang, query) then
        return false
    end
    return true
end

function M.foldexpr()
    return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0"
end

function M.indentexpr()
    return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1
end

function M.check()
    local is_win = vim.fn.has("win32") == 1
    ---@param tool string
    ---@param win boolean?
    local function have(tool, win)
        return (win == nil or is_win == win) and vim.fn.executable(tool) == 1
    end

    local ret = {
        ["tree-sitter (CLI)"] = have("tree-sitter"),
        ["C compiler"] = vim.env.CC or have("cc", false) or have("cl", true),
        tar = have("tar"),
        curl = have("curl"),
        node = have("node"),
    }
    local ok = true
    for _, v in pairs(ret) do
        ok = ok and v
    end
    return ok, ret
end

---@param cb fun()
function M.build(cb)
    M.ensure_treesitter_cli(function(_, err)
        local ok, health = M.check()
        if ok then
            return cb()
        else
            local lines = { "Unmet requirements for **nvim-treesitter** `main`:" }
            local keys = vim.tbl_keys(health) ---@type string[]
            table.sort(keys)
            for _, k in pairs(keys) do
                lines[#lines + 1] = ("- %s `%s`"):format(health[k] and "✅" or "❌", k)
            end
            vim.list_extend(lines, {
                "",
                "See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)",
                "Run `:checkhealth nvim-treesitter` for more information.",
            })
            vim.list_extend(lines, err and { "", err } or {})
            vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR, { title = "Treesitter" })
        end
    end)
end

---@param cb fun(ok:boolean, err?:string)
function M.ensure_treesitter_cli(cb)
    return cb(vim.fn.executable("tree-sitter") == 1)
end

return M
