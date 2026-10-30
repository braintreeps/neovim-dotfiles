-- Fails when a lockfile does not parse, a lazy-lock entry has no commit, a
-- lazy-lock entry is declared by no spec in lua/plugins, or a mason-lock.nvim
-- locked_packages entry is missing from mason-lock.json.
-- Run from the repo root: nvim --clean --headless -l scripts/ci/check_lockfiles.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
vim.opt.rtp:prepend(root)

local lockfiles = require("config.utils.lockfiles")
local lsp_contract = require("config.utils.lsp_contract")

local function fail(message)
    io.stderr:write(message .. "\n")
    os.exit(1)
end

local function read(name)
    local data, err = lockfiles.read_json(root .. "/" .. name)
    if not data then
        fail(name .. " is " .. err)
    end
    return data
end

local declared = lockfiles.declared_plugins(root .. "/lua/plugins")
local undeclared = {}
for name, entry in pairs(read("lazy-lock.json")) do
    if type(entry) ~= "table" or type(entry.commit) ~= "string" then
        fail("lazy-lock.json entry has no commit: " .. name)
    end
    -- Recipe-provided plugins carry a source and have no spec of their own.
    if entry.source == nil and not declared[name] then
        undeclared[#undeclared + 1] = name
    end
end
if #undeclared > 0 then
    table.sort(undeclared)
    fail("lazy-lock.json lists plugins no spec declares: " .. table.concat(undeclared, ", "))
end

local mason_lock = read("mason-lock.json")
local opts = lsp_contract.plugin_opts("cosmicbuffalo/mason-lock.nvim")
if not opts then
    fail("mason-lock.nvim spec not found in lua/plugins/lsp.lua")
end

local missing = lockfiles.unlocked_packages(opts.locked_packages, mason_lock)
if #missing > 0 then
    fail("Listed in locked_packages but missing from mason-lock.json: " .. table.concat(missing, ", "))
end
print("Lockfiles are consistent")
