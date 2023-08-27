local M = {}

function M.settings_file()
    return vim.loop.cwd() .. "/.vscode/settings.json"
end

---load settings.json
function M.load_settings()
    local file = io.open(M.settings_file())
    if file then
        local content = file:read("*a")
        local data = assert(vim.json.decode(content), ".vscode/settings.json must contain a JSON object") --[[@as table]]
        if data["editor.tabSize"] ~= nil then
            vim.opt.tabstop = data["editor.tabSize"]
            vim.opt.shiftwidth = data["editor.tabSize"]
        end
    end
end

---@class integrator.Settingsconfiguration: integrator.ModuleConfiguration

---setup settings module
---@param config integrator.Settingsconfiguration
function M.setup(config)
    local fs = require("integrator.fs")

    M.load_settings()
    local unwatch = fs.watch(M.settings_file(), {
        on_added = function()
            vim.schedule(function()
                M.load_settings()
            end)
        end,
        on_changed = function()
            vim.schedule(function()
                M.load_settings()
            end)
        end,
        on_deleted = function() end,
    })
end

return M
