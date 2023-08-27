---@module 'integrator.dap'
---@module 'integrator.session'
---@module 'integrator.settings'

local M = {}

---@class integrator.ModuleConfiguration
---@field enabled boolean enable/disable module

---@class integrator.Configuration
---@field dap? integrator.DapConfiguration
---@field session? integrator.SessionConfiguration
---@field settings? integrator.Settingsconfiguration

---@type integrator.Configuration
M.config = {
    dap = { enabled = false },
    overseer = { enabled = false },
    session = { enabled = false },
    settings = { enabled = true },
}

---comment
---@param config integrator.Configuration
function M.setup(config)
    M.config = vim.tbl_deep_extend("force", M.config, config)
    if M.config.dap.enabled then
        require("integrator.dap").setup(M.config.dap)
    end
    if M.config.session.enabled then
        require("integrator.session").setup(M.config.session)
    end
    if M.config.settings.enabled then
        require("integrator.settings").setup(M.config.settings)
    end
end

return M
