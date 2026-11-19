local java_executables = {}

local function java_executable(version)
    if java_executables[version] == nil then
        local ok, result = pcall(function()
            return vim.system({ "mise", "where", "java@" .. version }, { text = true }):wait()
        end)
        local home = ok and result.code == 0 and vim.trim(result.stdout) or ""
        java_executables[version] = home ~= "" and (home .. "/bin/java") or false
    end
    return java_executables[version] or nil
end

return {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
        local function setup_jdtls()
            local jdtls_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls/"
            if vim.fn.executable(jdtls_dir .. "bin/jdtls") == 0 then
                return
            end
            local jvmArg = "-javaagent:" .. jdtls_dir .. "lombok.jar"
            -- Mason only offers the latest jdtls, and current releases refuse to start on JDK 21.
            local server_java = java_executable("25")
            if not server_java then
                vim.schedule(function()
                    vim.notify(
                        "jdtls needs JDK 25 to run, and none was found through mise.\n"
                            .. "Install it with `mise install java@25` and reopen the file.\n"
                            .. "Projects can still target older Java versions.",
                        vim.log.levels.WARN,
                        { title = "jdtls" }
                    )
                end)
                return
            end

            local cmd = { jdtls_dir .. "bin/jdtls", "--jvm-arg=" .. jvmArg }
            table.insert(cmd, 2, "--java-executable=" .. server_java)

            local runtimes = {}
            for _, version in ipairs({ "11", "17", "21", "25" }) do
                local path = java_executable(version)
                if path then
                    table.insert(runtimes, { name = "JavaSE-" .. version, path = path })
                end
            end

            local config = {
                cmd = cmd,
                root_dir = vim.fs.root(0, { "gradlew", ".git", "mvnw" }),
                settings = {
                    java = {
                        completion = {
                            favoriteStaticMembers = {
                                "org.junit.Assert.*",
                                "org.mockito.Mockito.*",
                                "org.mockito.ArgumentMatchers.*",
                            },
                        },
                        referencesCodeLens = {
                            enabled = true,
                        },
                    },
                    configuration = {
                        runtimes = runtimes,
                    },
                },
            }

            require("jdtls").start_or_attach(config)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "java",
            callback = setup_jdtls,
        })
    end,
}
