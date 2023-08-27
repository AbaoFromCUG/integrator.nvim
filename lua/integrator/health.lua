local M = {}
local integrator = require("integrator")

function M.check()
    vim.health.report_start("integrator.nvim")
    local modules = { "dap", "session", "settings" }
    for _, module_name in ipairs(modules) do
        if integrator.config[module_name].enabled then
            vim.health.report_ok(string.format("%s enabled", module_name))
        else
            vim.health.report_warn(string.format("%s disabled", module_name))
        end
    end
end

return M
