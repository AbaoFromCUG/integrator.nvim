-- configuration resolver
local M = {}

local builtin_variables_map = {
    file = function()
        return vim.fn.expand("%:p")
    end,
    fileBasename = function()
        return vim.fn.expand("%:t")
    end,
    fileBasenameNoExtension = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r")
    end,
    fileDirname = function()
        return vim.fn.expand("%:p:h")
    end,
    fileExtname = function()
        return vim.fn.expand("%:e")
    end,
    relativeFile = function()
        return vim.fn.expand("%:.")
    end,
    relativeFileDirname = function()
        return vim.fn.fnamemodify(vim.fn.expand("%:.:h"), ":r")
    end,
    workspaceFolder = function()
        return vim.fn.getcwd()
    end,
    workspaceFolderBasename = function()
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    end,
    env = function(match)
        return os.getenv(match) or ""
    end,
    command = function(identifier)
        local handle = require("intergrater.commands").commands[identifier]
        local match = string.format("${command:%s}", identifier)
        local error, result
        if type(handle) == "function" then
            result = handle()
        end
        -- allow return a coroutine
        if type(result) == "thread" then
            vim.schedule(function()
                local success, e = coroutine.resume(result)
                if not success then
                    error = string.format("Can't resolve command variable:  % : %s", match, e)
                end
            end)
            result = coroutine.yield()
        end
        if result == nil or error then
            error = error or string.format("Can't resolve command variable:  %s : the command handle with type(%s)", match, type(handle))
            vim.notify(error, vim.log.levels.ERROR, { title = "Identifier" })
            return match
        end
        return result
    end,
}

---resolve a config, support:
---1. builtin variable
---2. environment variable
---3. command variable
---@param config table<string, table|any> Configuration
---@return table<string, table|any> # Result config
---@nodiscard
function M.resolve_config(config)
    local resolved_variables = {}
    local function _recusive(tbl)
        local result = {}
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                result[k] = _recusive(v)
            elseif type(v) == "string" then
                result[k] = M.resolve_string(v, resolved_variables)
            else
                result[k] = v
            end
        end
        setmetatable(result, getmetatable(tbl))
        return result
    end
    return _recusive(config)
end

---resolve a string, support variable
---@param str string
---@param resolved_variables? table<string, string>
---@return string the result
function M.resolve_string(str, resolved_variables)
    resolved_variables = resolved_variables or {}
    local re = "(${(.-)})"
    local result = str
    for match, identifier in str:gmatch(re) do
        local expand = str
        local variable, argument = unpack(vim.split(identifier, ":"))
        if resolved_variables[match] then
            expand = resolved_variables[match]
        elseif builtin_variables_map[variable] then
            expand = builtin_variables_map[variable](argument)
            resolved_variables[match] = expand
        end
        result = vim.fn.substitute(result, match, expand, "g")
    end
    return result
end

function M.resolve(value)
    if type(value) == "string" then
        return M.resolve_string(value)
    elseif type(value) == "table" then
        return M.resolve_config(value)
    end
    return value
end

return M
