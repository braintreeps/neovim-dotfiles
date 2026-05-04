vim.opt_local.path:append("**/src/*/java/**")
vim.opt_local.includeexpr = "substitute(v:fname, '\\.', '/', 'g')"
