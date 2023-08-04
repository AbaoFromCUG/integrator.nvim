describe("setup", function()
    describe("dap", function()
        before_each(function()
            package.loaded["dap"] = require("tests.intergrater.fake.dap")
        end)

        after_each(function()
            package.loaded["dap"] = nil
            package.loaded["tests.intergrater.fake.dap"] = nil
        end)

        it("adapter register order", function()
            local dap = require("dap")
            dap.adapters.funny = { name = "funny" }
            require("intergrater").setup({
                dap = {
                    enabled = true,
                },
            })
            dap.adapters.server = { name = "server" }

            assert.are.equal(type(dap.adapters["funny"].enrich_config), "function")
            assert.are.equal(type(dap.adapters["server"].enrich_config), "function")
        end)
        it("adapter enrich_config", function()
            local dap = require("dap")
            dap.adapters.funny = { name = "funny" }
            require("intergrater").setup({
                dap = {
                    enabled = true,
                },
            })

            local funny_adapter = dap.adapters["funny"]
            local config = {
                envFile = vim.fn.getcwd() .. "/tests/intergrater/.env",
                env = {
                    PATH = "/another/path",
                },
            }
            local expect = {
                envFile = vim.fn.getcwd() .. "/tests/intergrater/.env",
                env = {
                    PATH = "/another/path",
                    VALUE = "1",
                    LD_PATH = "/home/fake/ld",
                },
            }
            local called = 0
            funny_adapter.enrich_config(config, function(new_config)
                called = called + 1
                assert.are.same(expect, new_config)
            end)
            assert.are.equal(called, 1)
        end)

        it("adapter enrich_config with spec", function()
            local dap = require("dap")
            dap.adapters.funny = {
                name = "funny",
                enrich_config = function(config, on_config)
                    local new_config = vim.deepcopy(config)
                    new_config.new_name = "funny"
                    on_config(new_config)
                end,
            }
            require("intergrater").setup({
                dap = {
                    enabled = true,
                },
            })

            local funny_adapter = dap.adapters["funny"]
            local config = {
                envFile = vim.fn.getcwd() .. "/tests/intergrater/.env",
            }
            local expect = {
                new_name = "funny",
                envFile = vim.fn.getcwd() .. "/tests/intergrater/.env",
                env = {
                    PATH = "/a/path",
                    VALUE = "1",
                    LD_PATH = "/home/fake/ld",
                },
            }
            local called = 0
            funny_adapter.enrich_config(config, function(new_config)
                called = called + 1
                assert.are.same(expect, new_config)
            end)
            assert.are.equal(called, 1)
        end)
    end)
end)
