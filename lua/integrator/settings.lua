local json = require("integrator.json")

---@class integrator.SettingModule
local M = {}

---@generic T
---@alias integrator.SettingChangedHandler function(value: T)

---@type table<string, integrator.SettingChangedHandler>
local settings_watcher = {}

local settings = json.decode("{}")

function M.settings_file()
    return vim.loop.cwd() .. "/.vscode/settings.json"
end

---Subscribe setting changed
---@param key string
---@param handle function(value)
function M.on_setting_changed(key, handle)
    settings_watcher[key] = handle
end

function M.get_setting(key)
    return settings:get(key)
end

---load settings.json
function M._load_settings()
    local file = io.open(M.settings_file())
    if file then
        local content = file:read("*a")
        local new_settings = assert(json.decode(content), ".vscode/settings.json must contain a JSON object") --[[@as table]]

        for key, handle in pairs(settings_watcher) do
            local new, old = new_settings, settings
            local path = vim.split(key, "%.")
            for _, p in ipairs(path) do
                if new ~= nil then
                    new = new[p]
                end
                if old ~= nil then
                    old = old[p]
                end
                if new == nil and old == nil then
                    break
                end
            end
            if new ~= old then
                handle(new)
            end
        end
        settings = new_settings
    else
        settings = json.decode("{}")
    end
end

---@class integrator.Settingsconfiguration: integrator.ModuleConfiguration

---setup settings module
---@param config integrator.Settingsconfiguration
function M._setup(config)
    local fs = require("integrator.fs")

    local unwatch = fs.watch(M.settings_file(), {
        on_added = function()
            print("on_added")
            vim.schedule(function()
                M._load_settings()
            end)
        end,
        on_changed = function()
            print("on_changed")
            vim.schedule(function()
                M._load_settings()
            end)
        end,
        on_deleted = function() end,
    })

    M.on_setting_changed("editor.tabSize", function(value)
        vim.opt.tabstop = value
        vim.opt.shiftwidth = value
    end)
end

return M
