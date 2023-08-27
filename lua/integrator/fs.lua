local uv = vim.loop

local M = {}

---@class integrator.fs.WatchConfig
---@field on_added? fun(path:string, stat)
---@field on_changed? fun(path:string, stat)
---@field on_deleted? fun(path:string)

---comment
---@param path any
---@param opts integrator.fs.WatchConfig
function M.watch(path, opts)
    local timer = uv.new_timer()
    local init = false
    local mtime
    local function unwatch()
        timer:stop()
    end
    timer:start(0, 1000, function()
        local stat = uv.fs_stat(path)
        if not stat or stat.type ~= "file" then
            if init and mtime ~= nil then
                -- file deleted
                mtime = nil
                if opts.on_deleted then
                    opts.on_deleted(path)
                end
            end
        elseif stat.mtime.nsec ~= mtime then
            if init then
                if mtime == nil then
                    if opts.on_added then
                        opts.on_added(path, stat)
                    end
                else
                    if opts.on_changed then
                        opts.on_changed(path, stat)
                    end
                end
            end
            mtime = stat.mtime.nsec
        end
        init = true
    end)

    return unwatch
end

return M
