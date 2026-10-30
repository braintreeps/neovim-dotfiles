-- Requires every config, plugin spec, and health module without starting lazy.nvim.
-- Modules that need a plugin which is not installed here are skipped, so the check
-- fails only on syntax errors and on missing repo modules.
-- Run from the repo root: nvim --clean --headless -l scripts/ci/smoke.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
vim.opt.rtp:prepend(root)

local function is_repo_module(module)
    return vim.uv.fs_stat(root .. "/lua/" .. module:gsub("%.", "/") .. ".lua") ~= nil
        or vim.uv.fs_stat(root .. "/lua/" .. module:gsub("%.", "/") .. "/init.lua") ~= nil
end

local failures, skipped = {}, {}
for name, kind in vim.fs.dir(root .. "/lua", { depth = math.huge }) do
    if kind == "file" and name:match("%.lua$") then
        local module = name:gsub("%.lua$", ""):gsub("/init$", ""):gsub("/", ".")
        local ok, err = pcall(require, module)
        local external = not ok and tostring(err):match("module '([^']+)' not found")
        if ok then
            -- nothing to record
        elseif external and not is_repo_module(external) then
            skipped[#skipped + 1] = module
        else
            failures[#failures + 1] = module .. ": " .. tostring(err)
        end
    end
end

if #failures > 0 then
    io.stderr:write("Modules failed to load:\n" .. table.concat(failures, "\n") .. "\n")
    os.exit(1)
end
print(("Loaded config modules; skipped %d that need uninstalled plugins"):format(#skipped))
