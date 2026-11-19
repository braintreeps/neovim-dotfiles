vim.filetype.add({
    pattern = {
        [".*%.json%.tpl"] = "json",
        [".*%.ya?ml%.tpl"] = "yaml",
    },
})
