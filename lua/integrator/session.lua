local M = {}

---@class integrator.SessionConfiguration: integrator.ModuleConfiguration

---setup session, support necessed saved
---@param config integrator.SessionConfiguration
function M.setup(config)
    local launcher = require("integrator.launcher")
    local session = require("session")

    session.register_hook("pre_restore", "refresh_launchjs", function()
        launcher.reload()
    end)
    session.register_hook("extra_save", "save_selected_launch", function()
        local current_launch = launcher.selected_configuration
        if current_launch then
            return string.format("lua require('integrator.launcher').select_by_name('%s')", current_launch.name)
        end
    end)
end

return M
