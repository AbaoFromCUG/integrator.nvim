local M = {}
local integrator = require("integrator")

function M.check()
    vim.health.start("integrator.nvim")
    local modules = { "dap", "session", "settings" }
    for _, module_name in ipairs(modules) do
        if integrator.config[module_name].enabled then
            vim.health.ok(string.format("%s enabled", module_name))
        else
            vim.health.warn(string.format("%s disabled", module_name))
        end
    end
end

return M
