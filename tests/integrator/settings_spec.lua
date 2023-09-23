local spy = require("luassert.spy")

describe("settings", function()
    ---@type integrator.SettingModule
    local settings
    local tempfile
    local function write_settings(content)
        vim.fn.writefile({ vim.json.encode(content) }, tempfile)
        settings._load_settings()
    end

    before_each(function()
        package.loaded["integrator.settings"] = nil
        settings = require("integrator.settings")
        settings.settings_file = function()
            return tempfile
        end
        tempfile = vim.fn.tempname()
    end)

    it("get", function()
        write_settings({
            ["editor.tabSize"] = 2,
        })
        assert.are.equal(2, settings.get_setting("editor.tabSize"))
    end)

    it("add 1", function()
        local editor_changed = spy.new(function() end)
        settings.on_setting_changed("editor", editor_changed)

        local tabSize_changed = spy.new(function() end)
        settings.on_setting_changed("editor.tabSize", tabSize_changed)

        write_settings({
            ["editor.tabSize"] = 2,
        })
        assert.spy(editor_changed).was.called_with({ tabSize = 2 })
        assert.spy(tabSize_changed).was.called_with(2)
    end)
    it("add 2", function()
        local editor_changed = spy.new(function() end)
        settings.on_setting_changed("editor", editor_changed)

        local tabSize_changed = spy.new(function() end)
        settings.on_setting_changed("editor.tabSize", tabSize_changed)

        local wordWrap_changed = spy.new(function() end)
        settings.on_setting_changed("editor.wordWrap", wordWrap_changed)

        write_settings({
            editor = {
                tabSize = 2,
                wordWrap = 4,
            },
        })
        assert.spy(editor_changed).was.called_with({ tabSize = 2, wordWrap = 4 })
        assert.spy(tabSize_changed).was.called_with(2)
        assert.spy(wordWrap_changed).was.called_with(4)
    end)

    it("change", function()
        write_settings({
            ["editor.tabSize"] = 2,
        })
        local editor_changed = spy.new(function() end)
        settings.on_setting_changed("editor", editor_changed)

        local tabSize_changed = spy.new(function() end)
        settings.on_setting_changed("editor.tabSize", tabSize_changed)

        write_settings({
            ["editor.tabSize"] = 4,
        })
        assert.spy(editor_changed).was.called_with({ tabSize = 4 })
        assert.spy(tabSize_changed).was.called_with(4)
    end)
end)
