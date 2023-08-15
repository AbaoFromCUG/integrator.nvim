local M = {}
local integrator = require("integrator")

function M.check()
    vim.health.report_start("integrator.nvim")
    if integrator.config.dap.enabled then
        vim.health.report_ok("dap-launcher enabled")
    else
        vim.health.report_warn("dap-launcher disabled")
    end
    if integrator.config.session.enabled then
        vim.health.report_ok("session auto saved enabled")
    else
        vim.health.report_warn("session auto saved disabled")
    end
end

return M
