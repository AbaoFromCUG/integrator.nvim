local M = require("lualine.component"):extend()

local launcher = require("integrator.launcher")

---@class lualine.components.launcher.Options
---@field symbols table<string, string> adapter type map to icon

---lualine component show launcher info
---@param options lualine.components.launcher.Options
function M:init(options)
    local default_options = {
        on_click = launcher.select,
        symbols = {
            cppdbg = " ",
            nodejs = " ",
        },
    }
    options = vim.tbl_deep_extend("force", default_options, options)
    M.super.init(self, options)
end

function M:update_status()
    local config = launcher.selected_configuration
    if config then
        if self.options.icons_enabled then
            -- launch.json add `icon` property
            local icon = config.icon or self.options.symbols[config.type]
            icon = icon or require("nvim-web-devicons").get_icon(config.program)
            icon = icon or "🏃"
            return icon .. config.name
        else
            return config.name
        end
    end
end

return M
