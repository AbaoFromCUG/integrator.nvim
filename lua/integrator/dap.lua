local M = {}

---function for dap.adapter.enrich_config
---@param config table
---@param on_config function(table)
function M.enrich_config_hook(config, on_config)
    local final_config = vim.deepcopy(config)
    local path = final_config.envFile or vim.fn.getcwd() .. "/.env"
    local env = require("integrator.utils").read_env_file(path)
    if final_config.env then
        final_config.env = vim.tbl_extend("keep", final_config.env, env)
    else
        final_config.env = env
    end
    on_config(final_config)
end

local function inject_adapter(adapter)
    if type(adapter) == "table" then
        adapter._enrich_config = adapter.enrich_config
        adapter.enrich_config = function(old_config, on_config)
            if adapter._enrich_config then
                adapter._enrich_config(old_config, function(new_config)
                    M.enrich_config_hook(new_config, on_config)
                end)
            else
                M.enrich_config_hook(old_config, on_config)
            end
        end
        return adapter
    elseif type(adapter) == "function" then
        return function(on_resolved, config)
            adapter(function(_config)
                on_resolved(inject_adapter(_config))
            end, config)
        end
    end
end

---@class integrator.DapConfiguration: integrator.ModuleConfiguration

---inject dap
---@param config? integrator.DapConfiguration
function M.setup(config)
    --TODO: support config
    local dap = require("dap")
    dap._adapters = dap._adapters or {}
    setmetatable(dap.adapters, {
        __index = function(_, k)
            return dap._adapters[k]
        end,
        __newindex = function(_, k, v)
            dap._adapters[k] = inject_adapter(v)
        end,
    })
    -- mock dap
    dap.expand_config_variables = require("integrator.resolver").resolve
    for index, adapter in pairs(dap.adapters) do
        dap[index] = inject_adapter(adapter)
    end
end

return M
