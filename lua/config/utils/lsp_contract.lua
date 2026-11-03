local M = {}

--- Returns the opts of a plugin spec declared in lua/plugins/lsp.lua, searching dependencies too.
---@param name string
---@return table?
function M.plugin_opts(name)
    local function find(specs)
        for _, spec in ipairs(specs) do
            if type(spec) == "table" then
                if spec[1] == name then
                    return spec.opts
                end
                local found = find(spec.dependencies or {})
                if found then
                    return found
                end
            end
        end
    end
    return find(require("plugins.lsp"))
end

---@param server_defs table<string, table>
---@param filetype_tooling table<string, table>
---@return string[] problems empty when the contract holds
function M.validate(server_defs, filetype_tooling)
    local problems = {}
    for ft, tooling in pairs(filetype_tooling) do
        for _, server in ipairs(tooling.servers or {}) do
            if not server_defs[server] then
                local msg = "filetype_tooling.%s.servers: '%s' is not a key in server_defs"
                problems[#problems + 1] = msg:format(ft, server)
            end
        end
        for gem, server in pairs(tooling.gems or {}) do
            if not server_defs[server] then
                local msg = "filetype_tooling.%s.gems: '%s' (gem '%s') is not a key in server_defs"
                problems[#problems + 1] = msg:format(ft, server, gem)
            end
        end
    end
    table.sort(problems)
    return problems
end

return M
