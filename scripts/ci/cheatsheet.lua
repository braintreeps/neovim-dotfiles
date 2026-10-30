-- Regenerates CHEATSHEET.md in the repo root with the cheatsheet_generator.nvim install under stdpath("data").
-- The generator stamps today's date into the header, so that line is dropped to keep the output stable.
-- Run from the repo root: nvim --headless -l scripts/ci/cheatsheet.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local plugin_dir = vim.fn.stdpath("data") .. "/lazy/cheatsheet_generator.nvim"
if vim.fn.isdirectory(plugin_dir) == 0 then
    error("cheatsheet_generator.nvim is not installed at " .. plugin_dir)
end
vim.opt.rtp:prepend(plugin_dir)
vim.fn.chdir(root)

local generator = require("cheatsheet_generator")
local spec = dofile(root .. "/lua/plugins/cheatsheet_generator.lua")[1]
generator.setup(spec.opts)

-- Runs the external script directly: generator.generate() hard-codes ~/.config/nvim as the working directory.
local result = vim.system({
    vim.v.progpath,
    "--clean",
    "--headless",
    "-c",
    "set rtp+=.",
    "-l",
    plugin_dir .. "/lua/cheatsheet_generator/external_script.lua",
    vim.json.encode(generator.get_config()),
}, { cwd = root, text = true }):wait()
if result.code ~= 0 then
    error("cheatsheet generation failed:\n" .. result.stdout .. result.stderr)
end

local path = root .. "/CHEATSHEET.md"
local kept = {}
local lines = vim.fn.readfile(path)
local i = 1
while i <= #lines do
    if lines[i]:match("^Up to date as of: ") then
        i = i + ((lines[i + 1] == "") and 2 or 1)
    else
        kept[#kept + 1] = lines[i]
        i = i + 1
    end
end
vim.fn.writefile(kept, path)
print("Regenerated " .. path)
