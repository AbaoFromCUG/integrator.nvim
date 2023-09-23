
A infrastructure of neovim IDE; A bridge between various neovim plugins

# Install

**lazy.nvim**
```lua
return {
    "AbaoFromCUG/integrator.nvim",
    config = {
        dap = {
            enabled = true
        },
        session = {
            enabled = true
        },
        settings = {
            enabled = true
        }
    }
}
```

# Usages

## Commands

- [x] commmand variables
- [ ] integrate telescope

### Command Variables

```lua
require("integrator.commands").register_command("myplugin.spec", function()
    return "result"
end)

--for async style command variable, such as build task
require("integrator.commands").register_command("myplugin.another", function()
    local co = coroutine.running()
    return coroutine.create(function()
        vim.ui.select({ "A", "B" }, {}, function(item)
            coroutine.resume(co, item)
        end)
    end)
end)
```


## Variables

- [x] builtin variables
- [x] command variables
- [ ] input variables


In `.vscode/launch.json` or `dap.configurations`

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Desktop",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspace}/build/a.out",
            "arg": [
                "${command:myplugin.spec}",
                "${command:myplugin.another}",
                "${file}"
            ]
        }
    ]
}

```


## Launcher
- [x] select configuration
- [x] save/load state to session automatically
- [ ] multiple type launch
    - [x] dap
    - [x] plenary.test_harness
    - [ ] more unit test
- [x] launcher component (lualine.nvim)
- [x] auto save current launcher (session.nvim)
- [ ] dap.nvim 
    - [x] configuration support `envFile`
    - [x] inject `core.variables`

```lua
require("lualine").setup({
	sections = {
		lualine_c = {
			"launcher",
		},
	},
})
```
`envFile` in `.vscode/launch.json`
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Desktop",
            "type": "cppdbg",
            "request": "launch",
            "envFile": "${workspaceFolder}/.env",
        }
    ]
}

```


## Settings

Support vscode's style settings file `.vscode/settings.json`, watch file via timer

`.vscode/settings.json`
```json
{
    "editor.tabSize": 2
}
```


```lua
local settings = require("integrator.settings")
settings.on_setting_changed("editor.tabSize", function(new_tabSize) end)
settings.on_setting_changed("editor", function(new_editor) end)
```
