-- Ensure mise shims are on PATH so tools like node, tree-sitter, etc. are available
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(mise_shims) == 1 and not vim.env.PATH:find(mise_shims, 1, true) then
    vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.textwidth = 0 -- no hard line wraps
vim.opt.completeopt = "menuone,noselect,popup"
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.autoread = true
vim.opt.mouse = ""
vim.opt.undofile = true
vim.g.disable_fancy_winbar = true

vim.g.clipboard = "osc52"

--- Otherwise the gutter column bounces around as the LSP decides whether to
--- show diagnostics or not (which can change across edit modes).
vim.opt.signcolumn = "yes"

vim.g.ruby_indent_assignment_style = "variable"

-- stop scrolling when less than 5 lines would be visible
vim.opt.scrolloff = 5 -- same as vim_dotfiles
