-- Legacy general-purpose plugins: editing motions, git, test runners, and other tools not tied to one filetype.
-- Filetype packs are in legacy-filetypes.lua.
local LazyFileEvents = require("config.utils.lazy").LazyFileEvents

---@module 'lazy.types'
---@type LazyPluginSpec[]
return {
    { "arthurxavierx/vim-caser", event = LazyFileEvents }, -- Change word casing with vim motion
    -- vim-codefmt doesn't seem to work with Lazy
    -- TODO can this be deprecated in favor of another formatting tool?
    --  {
    --	  'google/vim-codefmt',
    --	  dependencies = { 'google/vim-glaive', 'google/vim-maktaba' },
    --  },
    --
    {
        "janko-m/vim-test",
        dependencies = {
            {
                "benmills/vimux",
                dependencies = {
                    "jgdavey/vim-turbux",
                    "samguyjones/vim-crosspaste",
                },
                keys = {
                    { "<Leader>rx", "<cmd>wa<CR> <cmd>VimuxCloseRunner<CR>", desc = "Close runner pane" },
                    { "<Leader>ri", "<cmd>wa<CR> <cmd>VimuxInspectRunner<CR>", desc = "Inspect runner pane" },
                    { "<Leader>vs", '"vy :call VimuxRunCommand(@v)<CR>', mode = "v", desc = "Run highlighted" },
                    { "<Leader>vs", 'vip "vy :call VimuxRunCommand(@v)<CR>', desc = "Run contiguous lines" },
                },
                init = function()
                    vim.g["test#strategy"] = "vimux"
                end,
            },
        },
        cmd = { "TestNearest", "TestFile", "TestLast" },
        keys = {
            { "<Leader>rb", "<cmd>wa<CR> <cmd>TestFile<CR>", desc = "Run buffer" },
            { "<Leader>rf", "<cmd>wa<CR> <cmd>TestNearest<CR>", desc = "Run focused" },
            { "<Leader>rl", "<cmd>wa<CR> <cmd>TestLast<CR>", desc = "Run last test again" },
        },
        init = function()
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*.java",
                callback = function()
                    local test_cmd = vim.fn.expand("%:p"):match("/src/(%w+Test)/") or "test"
                    vim.g["test#java#gradletest#test_cmd"] = test_cmd
                end,
            })
        end,
    },
    { "kshenoy/vim-signature", event = LazyFileEvents }, -- Used to add/remove/go-to marks
    { "kana/vim-textobj-user", lazy = true }, -- used to create custom text objects; TODO mark for deletion
    { "mattn/emmet-vim", lazy = true }, -- used for a expanding abbreviations/adding tags to HTML; TODO mark for deletion
    { "mileszs/ack.vim", lazy = true }, -- used for searching. We use fzf + rg; TODO mark for deletion
    {
        "pgr0ss/vim-github-url",
        event = LazyFileEvents,
        keys = {
            { "<LocalLeader>gh", "<cmd>GitHubURL<CR>", desc = "show URL to view the file under cursor on GitHub" },
        },
    },
    { "tfnico/vim-gradle", event = LazyFileEvents },
    {
        "tpope/vim-projectionist",
        lazy = false,
        priority = 12,
    },
    { "tpope/vim-fugitive" },
    { "tpope/vim-ragtag", event = LazyFileEvents },
    {
        "tpope/vim-rake",
        lazy = false,
        priority = 11,
        keys = {
            { "<Leader>AA", "<cmd>A<CR>", desc = "Alternate file" },
            { "<Leader>AV", "<cmd>AV<CR>", desc = "Alternate w/ Vertical Split" },
            { "<Leader>AS", "<cmd>AS<CR>", desc = "Alternate w/ Horizontal Split" },
        },
    },
    { "tpope/vim-repeat" },
    { "tpope/vim-rhubarb", event = LazyFileEvents },
    { "tpope/vim-surround" },
    { "tpope/vim-unimpaired" },
    { "tpope/vim-vinegar" },
    { "vim-scripts/Align", lazy = true },
    { "vim-scripts/matchit.zip", lazy = true },
    {
        "tweekmonster/wstrip.vim",
        ft = { "ruby", "lua", "java", "python", "c", "cpp", "sql", "puppet", "rust", "go" },
        config = function(plugin, _)
            vim.g.wstrip_highlight = 0

            vim.api.nvim_create_autocmd("FileType", {
                pattern = plugin.ft,
                callback = function()
                    vim.b.wstrip_highlight = 1
                end,
            })
            -- these settings adapted from https://github.com/braintreeps/vim_dotfiles/blob/master/vimrc#L97-L102
        end,
    },
    -- TODO Removable plugins??
    { "tpope/vim-abolish", event = LazyFileEvents },
    { "AndrewRadev/splitjoin.vim", event = LazyFileEvents },
    { "godlygeek/tabular", event = LazyFileEvents },
    { "bkad/CamelCaseMotion", event = LazyFileEvents },
    { "romainl/vim-qf", lazy = true },

    {
        -- Swap delimeted items
        "machakann/vim-swap",
        keys = {
            { "g>", desc = "Swap with next" },
            { "g<", desc = "Swap with previous" },
            { "gs", desc = "Swap interactive" },
        },
    },
    { "wellle/targets.vim" },
}
