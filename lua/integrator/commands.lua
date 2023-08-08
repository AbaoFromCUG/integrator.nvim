local M = {}

---@type {[string]: function} commands center
M.commands = {
    pickProcess = require("integrator.utils").pick_process,
}

--- Register command style varible, e.g. ${command: cmake.launchTarget}
---@param identifier string A unique identifier for the command
---@param command_handler function A command handler function, support async
function M.register_command(identifier, command_handler)
    M.commands[identifier] = command_handler
end

return M
