-- reference: https://www.aseprite.org/api/plugin
function init(plugin)
    print("Aseprite is initializing ASE Extension Boilerplate")

    -- we can use "plugin.preferences" as a table with fields for
    -- our plugin (these fields are saved between sessions)
    if plugin.preferences.count == nil then
        plugin.preferences.count = 0
    end

    -- group reference: https://github.com/aseprite/aseprite/blob/main/data/gui.xml
    plugin:newCommand{
        id = "ase_extension_boilerplate",
        title = "ASE Extension Boilerplate",
        group = "file_export",
        onclick = function()
            app.alert("OnClick called")
            plugin.preferences.count = plugin.preferences.count + 1
        end,
        onenabled = function()
            app.alert("OnEnabled called")
            return true | false
        end
    }
end

function exit(plugin)
    print("Aseprite is closing plugin, command was called " .. plugin.preferences.count .. " times")
end
