local M = {}

---@class integrator.ModuleConfiguration
---@field enabled boolean enable/disable module

---@class integrator.Configuration
---@field dap? integrator.DapConfiguration
---@field overseer? integrator.OverseerConfiguration

---@class integrator.DapConfiguration: integrator.ModuleConfiguration
---@class integrator.OverseerConfiguration: integrator.ModuleConfiguration

---@type integrator.Configuration
local default_config = {
    dap = { enabled = false },
    overseer = { enabled = false },
}

---comment
---@param config integrator.Configuration
function M.setup(config)
    config = vim.tbl_deep_extend("keep", config, default_config)
    if config.dap.enabled then
        require("integrator.dap").inject(config)
    end
end

return M
