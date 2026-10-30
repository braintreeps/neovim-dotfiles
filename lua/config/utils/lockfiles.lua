local M = {}

---@param path string
---@return table? data
---@return string? err
function M.read_json(path)
    local f = io.open(path, "r")
    if not f then
        return nil, "missing"
    end
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    if not ok or type(data) ~= "table" then
        return nil, "not valid JSON"
    end
    return data
end

---@param locked_packages string[]
---@param mason_lock table<string, string>
---@return string[] packages listed in locked_packages but absent from mason-lock.json
function M.unlocked_packages(locked_packages, mason_lock)
    local missing = {}
    for _, pkg in ipairs(locked_packages) do
        if mason_lock[pkg] == nil then
            missing[#missing + 1] = pkg
        end
    end
    return missing
end

return M
