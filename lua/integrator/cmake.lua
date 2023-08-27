local M = {}

---@class integrator.CMakeConfiguration: integrator.ModuleConfiguration

---setup cmake
---@param config integrator.CMakeConfiguration
function M.setup(config)
    local cmake = require("cmake-tools")
    -- require("integrator.commands").register_command("cmake.launchTargetPath", function()
    --     local co = coroutine.running()
    --     return coroutine.create(function()
    --         cmake.build({ band = false }, function()
    --             local result = config:get_launch_target()
    --             coroutine.resume(co, result.data)
    --         end)
    --     end)
    -- end)
end

return M
