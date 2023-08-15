local M = {}

---@class integrator.ModuleConfiguration
---@field enabled boolean enable/disable module
--
---@class integrator.DapConfiguration: integrator.ModuleConfiguration

---@class integrator.OverseerConfiguration: integrator.ModuleConfiguration

---@class integrator.SessionConfiguration: integrator.ModuleConfiguration

---@class integrator.Configuration
---@field dap? integrator.DapConfiguration
---@field overseer? integrator.OverseerConfiguration
---@field session? integrator.SessionConfiguration

---@type integrator.Configuration
M.config = {
    dap = { enabled = false },
    overseer = { enabled = false },
    session = { enabled = false },
}

---comment
---@param config integrator.Configuration
function M.setup(config)
    M.config = vim.tbl_deep_extend("keep", config, M.config)
    if M.config.dap.enabled then
        require("integrator.dap").inject(M.config.dap)
    end
    if M.config.session.enabled then
        require("integrator.session").inject(M.config.session)
    end
end

return M
