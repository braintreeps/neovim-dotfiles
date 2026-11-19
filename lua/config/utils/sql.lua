local M = {}

local modifiers = {
    "TEMP",
    "TEMPORARY",
    "TRANSIENT",
    "VOLATILE",
    "LOCAL",
    "GLOBAL",
    "SECURE",
    "RECURSIVE",
    "MATERIALIZED",
    "DYNAMIC",
    "ICEBERG",
    "HYBRID",
    "EXTERNAL",
    "EVENT",
}

local types = {
    "PROCEDURE",
    "FUNCTION",
    "TABLE",
    "VIEW",
    "TASK",
    "STREAM",
    "SEQUENCE",
    "STAGE",
    "FILE\\s+FORMAT",
    "ALERT",
    "PIPE",
    "TAG",
    "MASKING\\s+POLICY",
    "ROW\\s+ACCESS\\s+POLICY",
}

local qualifier = [[(?:[\w${}"]+\.)]]

local function escape(text)
    return (text:gsub("[%^%$%.%[%]%*%+%-%?%(%)%{%}|\\]", "\\%0"))
end

--- Returns the name and optional schema of the dotted, possibly quoted identifier under the cursor.
---@return string? name
---@return string? schema
function M.identifier_at_cursor()
    local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2] + 1
    local init = 1
    while true do
        local first, last = line:find('[%w_$.{}"]+', init)
        if not first then
            return nil
        end
        if col <= last then
            if col < first then
                return nil
            end
            local parts = vim.split((line:sub(first, last):gsub('"', "")), ".", { plain = true, trimempty = true })
            return parts[#parts], parts[#parts - 1]
        end
        init = last + 1
    end
end

---@param name string
---@param schema string?
---@return string
function M.create_pattern(name, schema)
    local prefix = schema and (qualifier .. [[*"?]] .. escape(schema) .. [["?\.]]) or (qualifier .. "*")
    return table.concat({
        [[^\s*CREATE\s+(?:OR\s+(?:REPLACE|ALTER)\s+)?(?:(?:]],
        table.concat(modifiers, "|"),
        [[)\s+)*(?:]],
        table.concat(types, "|"),
        [[)\s+(?:IF\s+NOT\s+EXISTS\s+)?]],
        prefix,
        [["?]],
        escape(name),
        [["?(?:[\s(;]|$)]],
    })
end

---@param pattern string
---@param root string
---@return string[]
local function search(pattern, root)
    local result = vim.system({ "rg", "--vimgrep", "--ignore-case", "--regexp", pattern, root }, { text = true }):wait()
    return vim.split(result.stdout or "", "\n", { trimempty = true })
end

function M.goto_definition()
    if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" }) > 0 then
        return vim.lsp.buf.definition()
    end
    local name, schema = M.identifier_at_cursor()
    if not name then
        return vim.notify("No identifier under cursor", vim.log.levels.WARN, { title = "SQL" })
    end
    local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
    local lines = schema and search(M.create_pattern(name, schema), root) or {}
    if #lines == 0 then
        lines = search(M.create_pattern(name), root)
    end
    if #lines == 0 then
        return vim.notify("No CREATE statement found for " .. name, vim.log.levels.WARN, { title = "SQL" })
    end
    vim.fn.setqflist({}, " ", { lines = lines, efm = "%f:%l:%c:%m", title = "Definitions of " .. name })
    if #lines == 1 then
        vim.cmd("normal! m'")
        vim.cmd.cfirst()
    else
        vim.cmd.copen()
    end
end

return M
