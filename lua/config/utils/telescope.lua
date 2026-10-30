-- Telescope helpers for the pickers configured in lua/plugins/ui-telescope.lua
local Utils = require("config.utils")
local M = {}

local git_root_cache = {}
local _no_ignore = false

local file_pickers = {
    ["Find Files"] = "find_files",
    ["Git Files"] = "git_files",
    ["Live Grep"] = "live_grep",
    ["Grep String"] = "grep_string",
}

function M.toggle_no_ignore(prompt_bufnr)
    local action_state = require("telescope.actions.state")
    local picker = action_state.get_current_picker(prompt_bufnr)
    local base_title = picker.prompt_title:gsub(" %(no_ignore%)$", "")

    local builtin_name = file_pickers[base_title]
    if not builtin_name then
        vim.notify("no_ignore is not applicable to this picker", vim.log.levels.WARN)
        return
    end

    _no_ignore = not _no_ignore

    local title = base_title
    if _no_ignore then
        title = title .. " (no_ignore)"
    end

    require("telescope.builtin")[builtin_name]({
        default_text = picker:_get_prompt(),
        no_ignore = _no_ignore,
        prompt_title = title,
    })
end

-- Find files from project root (git root if available, otherwise current directory)
function M.find_files_from_project_git_root()
    local opts = Utils.lazy.opts("telescope.nvim").pickers.find_files or {}
    local cwd = vim.fn.getcwd()

    local cache_key = cwd
    if git_root_cache[cache_key] == nil then
        local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+$", "")
        if vim.v.shell_error == 0 and git_root ~= "" and vim.fn.isdirectory(git_root) == 1 then
            git_root_cache[cache_key] = { is_git = true, root = git_root }
        else
            git_root_cache[cache_key] = { is_git = false, root = cwd }
        end
    end

    local cache_entry = git_root_cache[cache_key]
    local search_opts = vim.tbl_deep_extend("force", opts, { cwd = cache_entry.root })

    if cache_entry.is_git then
        require("telescope.builtin").git_files(search_opts)
    else
        require("telescope.builtin").find_files(search_opts)
    end
end

function M.open_plugin_explorer()
    require("telescope.builtin").find_files({
        cwd = require("lazy.core.config").options.root,
        prompt_title = "Plugin Files",
    })
end

function M.open_buffer_explorer()
    require("telescope.builtin").buffers({
        sort_mru = true,
        attach_mappings = function(prompt_bufnr, map)
            local action_state = require("telescope.actions.state")
            local bd = require("mini.bufremove").delete
            local delete_buffer = function()
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                current_picker:delete_selection(function(selection)
                    local bufnr = selection.bufnr
                    local force = vim.bo[bufnr].buftype == "terminal"
                    if force then
                        return pcall(vim.api.nvim_buf_delete, bufnr, { force = force })
                    elseif vim.fn.getbufvar(bufnr, "&modified") == 1 then
                        -- stylua: ignore
                        local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname(bufnr)),
                            "&Yes\n&No\n&Cancel")
                        if choice == 1 then -- Yes
                            vim.api.nvim_buf_call(bufnr, function()
                                vim.cmd("write")
                            end)
                            return bd(bufnr)
                        elseif choice == 2 then -- No
                            return bd(bufnr, true)
                        end
                    else
                        return bd(bufnr)
                    end
                end)
            end
            map("n", "d", delete_buffer)
            return true
        end,
    })
end

function M.scope_to_dir(prompt_bufnr, picker)
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local fb = require("telescope").extensions.file_browser
    local current_line = action_state.get_current_line()

    fb.file_browser({
        files = false,
        depth = false,
        follow_symlinks = true,
        no_ignore = true,
        display_stat = { date = false, size = false, mode = false },
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local entry_path = action_state.get_selected_entry().Path
                local dir = entry_path:is_dir() and entry_path or entry_path:parent()
                local relative = dir:make_relative(vim.fn.getcwd())
                local absolute = dir:absolute()

                picker({
                    results_title = relative .. "/",
                    cwd = absolute,
                    default_text = current_line,
                })
            end)

            return true
        end,
    })
end

return M
