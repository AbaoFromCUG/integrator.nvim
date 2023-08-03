local M = {}

---@class intergrater.ModuleConfiguration
---@field enabled boolean enable/disable module

---@class intergrater.Configuration
---@field dap? intergrater.DapConfiguration
---@field overseer? intergrater.OverseerConfiguration

---@class intergrater.DapConfiguration: intergrater.ModuleConfiguration
---@class intergrater.OverseerConfiguration: intergrater.ModuleConfiguration

---@type intergrater.Configuration
local default_config = {
    dap = { enabled = false },
    overseer = { enabled = false },
}

---comment
---@param config intergrater.Configuration
function M.setup(config)
    config = vim.tbl_deep_extend("keep", config, default_config)
    if config.dap.enabled then
        require("intergrater.dap").inject(config)
    end
end

return M
