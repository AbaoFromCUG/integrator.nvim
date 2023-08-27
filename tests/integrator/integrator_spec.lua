local spy = require("luassert.spy")

local match = require("luassert.match")

describe("setup", function()
    describe("dap", function()
        before_each(function()
            package.loaded["dap"] = require("tests.integrator.fake.dap")
        end)

        after_each(function()
            package.loaded["dap"] = nil
            package.loaded["tests.integrator.fake.dap"] = nil
        end)

        it("adapter register order", function()
            local dap = require("dap")
            dap.adapters.funny = { name = "funny" }
            require("integrator").setup({
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
            require("integrator").setup({
                dap = {
                    enabled = true,
                },
            })

            local funny_adapter = dap.adapters["funny"]
            local config = {
                envFile = vim.fn.getcwd() .. "/tests/integrator/.env",
                env = {
                    PATH = "/another/path",
                },
            }
            local expect = {
                envFile = vim.fn.getcwd() .. "/tests/integrator/.env",
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

        it("adapter function inject", function()
            local dap = require("dap")
            dap.adapters.funny = function(on_config, config)
                on_config(config)
            end
            require("integrator").setup({
                dap = {
                    enabled = true,
                },
            })
            local funny = dap["funny"]
            assert.are.equal(type(funny), "function")

            local hook = spy.new(function() end)
            funny(hook, {})
            assert.spy(hook).was.called_with(match.is_table())
        end)

        it("adapter function enrich_config", function()
            local dap = require("dap")
            local hook = spy.new(function() end)
            dap.adapters.funny = function(on_config, config)
                on_config({
                    type = "server",
                    enrich_config = function(config, on_config)
                        hook(config)
                        on_config(config)
                    end,
                })
            end
            require("integrator").setup({
                dap = {
                    enabled = true,
                },
            })
            local funny = dap["funny"]
            assert.are.equal(type(funny), "function")
            local resolved_adapter
            local mark_arg = { mark = true }
            funny(function(resolved)
                resolved_adapter = resolved
                resolved_adapter.enrich_config(mark_arg, function(config) end)
            end, {})
            -- print(vim.inspect(resolved_adapter))
            assert.equals(type(resolved_adapter), "table")
            assert.equals(resolved_adapter.type, "server")
            assert.spy(hook).was.called_with(mark_arg)
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
            require("integrator").setup({
                dap = {
                    enabled = true,
                },
            })

            local funny_adapter = dap.adapters["funny"]
            local config = {
                envFile = vim.fn.getcwd() .. "/tests/integrator/.env",
            }
            local expect = {
                new_name = "funny",
                envFile = vim.fn.getcwd() .. "/tests/integrator/.env",
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
