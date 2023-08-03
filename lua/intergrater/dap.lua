local M = {}
function M.enrich_config_hook(config, on_config)
    local final_config = vim.deepcopy(config)
    local path = final_config.envFile or vim.fn.getcwd() .. "/.env"
    local env = require("intergrater.utils").read_env_file(path)
    if final_config.env then
        final_config.env = vim.tbl_extend("keep", final_config.env, env)
    else
        final_config.env = env
    end
    on_config(final_config)
end

local function inject_adapter(adapter)
    adapter._enrich_config = adapter.enrich_config
    adapter.enrich_config = function(old_config, on_config)
        if adapter._enrich_config then
            adapter._enrich_config(old_config, function(new_config)
                require("intergrater.dap").enrich_config_hook(new_config, on_config)
            end)
        else
            require("intergrater.dap").enrich_config_hook(old_config, on_config)
        end
    end
end

---injuct dap
---@param config? intergrater.DapConfiguration
function M.inject(config)
    local dap = require("dap")
    setmetatable(dap.adapters, {
        __index = function(_, k)
            return dap._adapters[k]
        end,
        __newindex = function(_, k, v)
            dap._adapters = dap._adapters or {}
            inject_adapter(v)
            dap._adapters[k] = v
        end,
    })
    -- mock dap
    dap.expand_config_variables = require("intergrater.variable_resolve").resolve
    for _, adapter in pairs(dap.adapters) do
        inject_adapter(adapter)
    end
end

return M
