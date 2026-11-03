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

local function plugin_name(spec)
    if type(spec.name) == "string" then
        return spec.name
    end
    local source = spec[1] or spec.url or spec.dir
    if type(source) == "string" then
        return (source:match("([^/]+)$"):gsub("%.git$", ""))
    end
end

local function collect_names(spec, names)
    if type(spec) == "string" then
        names[plugin_name({ spec })] = true
    elseif type(spec) == "table" then
        if type(spec[1]) == "string" then
            names[plugin_name(spec)] = true
            collect_names(spec.dependencies, names)
        else
            for _, child in ipairs(spec) do
                collect_names(child, names)
            end
        end
    end
end

---@param plugins_dir string directory holding this repo's plugin spec files
---@return table<string, true> names plugins declared by the spec files in plugins_dir
function M.declared_plugins(plugins_dir)
    local names = {}
    for _, file in ipairs(vim.fn.glob(plugins_dir .. "/*.lua", false, true)) do
        local ok, specs = pcall(dofile, file)
        if ok then
            collect_names(specs, names)
        end
    end
    return names
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
