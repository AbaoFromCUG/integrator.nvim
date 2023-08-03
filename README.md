# Intergrater.nvim

* A infrastructure of neovim IDE
* A bridge between various neovim plugins

<!-- TOC -->

## Install

**lazy.nvim**
```lua
{
	"AbaoFromCUG/intergrater.nvim",
    config = {
        dap = {
            enabled = true
        },
        overseer = {
            enabled = false
        }
    }
}
```

## Usages


### Core

**Commands**
- [x]register commands
- [ ]execute from telescope/cmd

```lua
require("intergrater.commands").register_command("myplugin.spec", function()
	return "result"
end)

--for async style command variable, such as build task
require("intergrater.commands").register_command("myplugin.another", function()
	local co = coroutine.running()
	return coroutine.create(function()
		vim.ui.select({ "A", "B" }, {}, function(item)
			coroutine.resume(co, item)
		end)
	end)
end)
```

**Variables**
- [x]builtin variables
- [x]command variables
- [ ]input variables

In `.vscode/launch.json` or `dap.configurations`

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Desktop",
            "type": "cppdbg",
            "request": "launch",
            "arg": [
                "${command:myplugin.spec}",
                "${command:myplugin.another}"
            ]
        }
    ]
}


```


**Launcher**
- [x]select configuration
- [x]save/load state to session automatically
- [ ]multiple type launch
    - [x]dap
    - [x]plenary.test_harness
    - [ ]more unit test

### Intergrate

**nvim-dap**
- [x]configuration support `envFile`
- [x]inject `core.variables`


**lualine**
- [x]launcher component

```lua
require("lualine").setup({
	sections = {
		lualine_c = {
			"launcher",
		},
	},
})
```
