local M = {}

---get process list
---@return {pid: number, name: string}[]
---@source https://github.com/mfussenegger/nvim-dap/blob/master/lua/dap/utils.lua
function M.get_processes()
    local is_windows = vim.fn.has("win32") == 1
    local separator = is_windows and "," or " \\+"
    local command = is_windows and { "tasklist", "/nh", "/fo", "csv" } or { "ps", "ah", "-U", os.getenv("USER") }
    -- output format for `tasklist /nh /fo` csv
    --    '"smss.exe","600","Services","0","1,036 K"'
    -- output format for `ps ah`
    --    " 107021 pts/4    Ss     0:00 /bin/zsh <args>"
    local get_pid = function(parts)
        if is_windows then
            return vim.fn.trim(parts[2], '"')
        else
            return parts[1]
        end
    end

    local get_process_name = function(parts)
        if is_windows then
            return vim.fn.trim(parts[1], '"')
        else
            return table.concat({ unpack(parts, 5) }, " ")
        end
    end

    local output = vim.fn.system(command)
    local lines = vim.split(output, "\n")
    local procs = {}

    local nvim_pid = vim.fn.getpid()
    for _, line in pairs(lines) do
        if line ~= "" then -- tasklist command outputs additional empty line in the end
            local parts = vim.fn.split(vim.fn.trim(line), separator)
            local pid, name = get_pid(parts), get_process_name(parts)
            pid = tonumber(pid)
            if pid and pid ~= nvim_pid then
                table.insert(procs, { pid = pid, name = name })
            end
        end
    end

    return procs
end

---pick a process, return a coroutine
---@param opts? table options for `vim.ui.select`
---@source ./commands.lua
function M.pick_process(opts)
    local co = coroutine.running()
    return coroutine.create(function()
        vim.ui.select(M.get_processes(), opts or {}, function(item)
            coroutine.resume(co, item.pid)
        end)
    end)
end

function M.read_env_file(path)
    local result = vim.empty_dict()
    if vim.loop.fs_stat(path) then
        for line in io.lines(path) do
            line = vim.trim(line)
            local kv = vim.split(line, "=")
            result[kv[1]] = kv[2]
        end
    end
    return result
end
return M
