-- Fails when filetype_tooling names a server or gem target that server_defs does not define.
-- Run from the repo root: nvim --clean --headless -l scripts/ci/check_contract.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
vim.opt.rtp:prepend(root)

local lsp_contract = require("config.utils.lsp_contract")
local opts = lsp_contract.plugin_opts("neovim/nvim-lspconfig")
if not opts then
    io.stderr:write("nvim-lspconfig spec not found in lua/plugins/lsp.lua\n")
    os.exit(1)
end

local problems = lsp_contract.validate(opts.server_defs, opts.filetype_tooling)
if #problems > 0 then
    io.stderr:write(table.concat(problems, "\n") .. "\n")
    os.exit(1)
end
print("LSP contract holds")
