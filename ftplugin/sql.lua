vim.keymap.set("n", "gd", function()
    require("config.utils").sql.goto_definition()
end, { buffer = true, desc = "SQL: [g]o to [d]efinition (CREATE statement)" })
