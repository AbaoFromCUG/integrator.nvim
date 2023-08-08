describe("variable.builtin", function()
    it("expand file", function()
        local result = require("integrator.variable_resolve").resolve_string("${file}")
        assert.are.equal(vim.fn.expand("%:p"), result)
    end)

    it("expand relativeFile", function()
        local result = require("integrator.variable_resolve").resolve_string("${relativeFile}")
        assert.are.equal(vim.fn.expand("%:."), result)
    end)
    it("expand file multiply", function()
        local result = require("integrator.variable_resolve").resolve_string("${file}-${fileBasename}-${file}")
        assert.are.equal(vim.fn.expand("%:p") .. "-" .. vim.fn.expand("%:t") .. "-" .. vim.fn.expand("%:p"), result)
    end)

    it("expand workspaceFolder", function()
        local result = require("integrator.variable_resolve").resolve_string("--${workspaceFolder}--")
        assert.are.equal("--" .. vim.fn.getcwd() .. "--", result)
    end)
end)

describe("variable.env", function()
    it("expand env:HOME", function()
        local home = require("integrator.variable_resolve").resolve_string("${env:HOME}")
        assert.are.equal(os.getenv("HOME"), home)

        local not_home = require("integrator.variable_resolve").resolve_string("env:HOME")
        assert.are.equal("env:HOME", not_home)
    end)

    it("expand env complex", function()
        do
            local result = require("integrator.variable_resolve").resolve_string("${env:HOME}--${env:PATH}")
            assert.are.equal(os.getenv("HOME") .. "--" .. os.getenv("PATH"), result)
        end
        do
            local result = require("integrator.variable_resolve").resolve_string("${env:HOME}--${env:PATH}--${env:HOME}")
            assert.are.equal(os.getenv("HOME") .. "--" .. os.getenv("PATH") .. "--" .. os.getenv("HOME"), result)
        end
    end)
end)

describe("variable.command", function()
    it("pickProcess", function()
        local options
        -- mock vim.ui.select
        vim.ui.select = function(options_, _, on_choice)
            options = options_
            vim.defer_fn(function()
                on_choice(options_[1])
            end, 1000)
        end
        local result = require("integrator.variable_resolve").resolve_string("${command:pickProcess}")
        -- pid is number
        assert.is_not_nil(options)
        assert.are.equal(tostring(options[1].pid), result)
    end)

    it("function handle", function()
        require("integrator.commands").register_command("test", function()
            return "value"
        end)

        local result = require("integrator.variable_resolve").resolve_string("${command:test}")
        assert.are.equal("value", result)
    end)

    it("call once", function()
        local count = 0
        require("integrator.commands").register_command("test", function()
            count = count + 1
            return "value"
        end)

        local result = require("integrator.variable_resolve").resolve_string("${command:test}-${command:test}")
        assert.are.equal("value-value", result)
        assert.are.equal(1, count)
    end)

    it("function return coroutine", function()
        require("integrator.commands").register_command("coroutine", function()
            local co = coroutine.running()
            return coroutine.create(function()
                vim.defer_fn(function()
                    coroutine.resume(co, "defer_value")
                end, 1000)
            end)
        end)
        local result = require("integrator.variable_resolve").resolve_string("${command:coroutine}")
        assert.are.equal("defer_value", result)
    end)
end)

describe("config.resolve", function()
    it("without process", function()
        local config = {
            name = "app",
            count = 1,
        }
        local expect = {
            name = "app",
            count = 1,
        }
        local result = require("integrator.variable_resolve").resolve_config(config)
        assert.are.same(expect, result)
    end)

    it("one level", function()
        local config = {
            name = "${workspaceFolderBasename}",
            key = "${env:HOME}",
        }
        local expect = {
            name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
            key = os.getenv("HOME"),
        }
        local result = require("integrator.variable_resolve").resolve_config(config)
        assert.are.same(expect, result)
    end)

    it("nested table", function()
        local config = {
            name = "${fileBasenameNoExtension}",
            key = "${env:HOME}",
            tbl = {
                subkey = "${fileBasenameNoExtension}",
            },
            array = {
                "${fileExtname}",
                "${env:PATH}",
            },
        }

        local expect = {
            name = vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r"),
            key = os.getenv("HOME"),
            tbl = {
                subkey = vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r"),
            },
            array = {
                vim.fn.expand("%:e"),
                os.getenv("PATH"),
            },
        }
        local result = require("integrator.variable_resolve").resolve_config(config)
        assert.are.same(expect, result)
    end)
end)

describe("config.misc", function()
    it("call once per match", function()
        local count = 0
        require("integrator.commands").register_command("test", function()
            count = count + 1
            return "value"
        end)

        local config = {
            name = "-${command:test}-${command:test}",
            sub = {
                key = "${command:test}",
            },
            array = {
                "${command:test}",
                "${command:test}",
            },
        }
        local expect = {
            name = "-value-value",
            sub = {
                key = "value",
            },
            array = {
                "value",
                "value",
            },
        }
        local result = require("integrator.variable_resolve").resolve_config(config)
        assert.are.same(expect, result)
    end)

    it("keep metatable", function()
        local function func1() end
        local function func2() end
        local config = {
            name = "${env:PATH}",
            f = func1,
            sub = {
                key = "${env:HOME}",
                f = func2,
            },
        }
        local M = {}
        function M:func() end
        setmetatable(config, M)
        local expect = {
            name = os.getenv("PATH"),
            f = func1,
            sub = {
                key = os.getenv("HOME"),
                f = func2,
            },
        }
        setmetatable(expect, M)

        local result = require("integrator.variable_resolve").resolve_config(config)
        assert.are.same(expect, result)
        assert.are.same(getmetatable(expect), getmetatable(result))
    end)
end)
