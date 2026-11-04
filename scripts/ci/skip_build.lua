-- Skips plugin builds that need network access. Load it before init.lua so it applies to the
-- install lazy.nvim runs inside setup(): nvim --headless --cmd "luafile scripts/ci/skip_build.lua"
local skipped = { ["vim-go"] = true }

vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
local build = require("lazy.manage.task.plugin").build
local skip = build.skip
build.skip = function(plugin, opts)
    return skipped[plugin.name] or skip(plugin, opts)
end
