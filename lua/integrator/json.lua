local M = {}

local Json = {}
Json.__index = Json
function Json.get(self, key)
    local path = vim.split(key, "%.")
    local current_tbl = self
    for _, p in ipairs(path) do
        if current_tbl ~= nil then
            current_tbl = current_tbl[p]
        else
            break
        end
    end
    return current_tbl
end

---decode json-str to table-json
---@param raw string
---@return table<string, number|string|table>
function M.decode(raw, flatten)
    local tbl = vim.json.decode(raw)
    tbl = M.flatten(tbl)
    return setmetatable(tbl, Json)
end

function M.flatten(json)
    local function _flatten(tbl)
        if type(tbl) == "string" or type(tbl) == "number" then
            return tbl
        elseif vim.tbl_islist(tbl) then
            local ctbl = {}
            for _, value in ipairs(tbl) do
                table.insert(ctbl, _flatten(value))
            end
            return ctbl
        else
            local ctbl = {}
            for key, value in pairs(tbl) do
                local path = vim.split(key, "%.")
                local current_tbl = ctbl
                for i = 1, #path - 1, 1 do
                    current_tbl[path[i]] = {}
                    current_tbl = current_tbl[path[i]]
                end
                current_tbl[path[#path]] = _flatten(value)
            end
            return ctbl
        end
    end
    return _flatten(json)
end

return M
