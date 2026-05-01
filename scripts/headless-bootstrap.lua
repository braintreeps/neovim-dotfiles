local data_dir = vim.fn.stdpath("data")
local config_dir = vim.fn.stdpath("config")

vim.opt.rtp:prepend(data_dir .. "/lazy/lazy.nvim")
vim.opt.rtp:prepend(data_dir .. "/lazy/nvim-treesitter")
package.path = config_dir .. "/lua/?.lua;" .. config_dir .. "/lua/?/init.lua;" .. package.path

local ok, utils = pcall(require, "config.utils.treesitter")
if not ok then
  io.stderr:write("Failed to load config.utils.treesitter: " .. tostring(utils) .. "\n")
  os.exit(1)
end

local languages = utils.ensure_installed
print("Installing " .. #languages .. " parsers...")

local install = require("nvim-treesitter.install")
local task = install.install(languages, { force = true, summary = true })
local success = task:wait(300000)

if not success then
  io.stderr:write("Parser installation failed or timed out\n")
  os.exit(1)
end

print("All parsers installed successfully")
