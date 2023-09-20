local M = {}

M.selected_configuration = nil

local function format_config(config)
    if config then
        return string.format("%s (%s)", config.name, config.type)
    end
    return ""
end

---clear dap.configurations, and read `.vscode/luanch.json`
function M.reload()
    local dap = require("dap")
    local fake_vscode = require("dap.ext.vscode")
    -- clear old configuration
    dap.configurations = {}
    fake_vscode.load_launchjs()
end

---get all configurations
function M.configurations()
    M.reload()
    local dap = require("dap")
    local flatten_configs = {}
    for _, subconfigs in pairs(dap.configurations) do
        for _, item in ipairs(subconfigs) do
            table.insert(flatten_configs, item)
        end
    end
    return flatten_configs
end

---select a configuration from list
function M.select()
    local configs = M.configurations()
    if vim.tbl_isempty(configs) then
        vim.notify("No configuration, please check launch.json" .. vim.inspect(configs), vim.log.levels.WARN, { title = "Integrator" })
        return
    end
    vim.ui.select(configs, {
        format_item = format_config,
    }, function(item)
        if item then
            M.selected_configuration = item
        end
    end)
end

---select a configuration by name
function M.select_by_name(name)
    local dap = require("dap")
    for _, subconfigs in pairs(dap.configurations) do
        for _, item in ipairs(subconfigs) do
            if item.name == name then
                M.selected_configuration = item
                return
            end
        end
    end
    vim.notify(string.format("no named (%s) launch", name), vim.log.levels.WARN, { title = "Integrator" })
end

---start debug with selected_configuration
function M.run()
    local current_file = vim.fn.expand("%:p")
    local dap = require("dap")
    if current_file and current_file:sub(-#"_spec.lua") == "_spec.lua" then
        local minimal = vim.loop.cwd() .. "/tests/minimal_init.lua"
        require("plenary.test_harness").test_file(current_file)
    elseif dap.session() then
        dap.continue()
    elseif M.selected_configuration then
        dap.run(M.selected_configuration)
    else
        vim.notify("not selected launch, please edit launch.json or refresh", vim.log.levels.WARN, { title = "Integrator" })
    end
end

---terminated debugger
function M.terminate()
    local dap = require("dap")
    dap.terminate()
end

---run build via overseer
function M.build()
    local overseer = require("overseer")
    overseer.run_template()
end

return M
