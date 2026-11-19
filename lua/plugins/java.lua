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
            local server_java = java_executable("25") or java_executable("21")

            local cmd = { jdtls_dir .. "bin/jdtls", "--jvm-arg=" .. jvmArg }
            if server_java then
                table.insert(cmd, 2, "--java-executable=" .. server_java)
            end

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
