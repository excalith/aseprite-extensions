-- Local Variables
local active_layer
local active_sprite
local strip_options = {"Horizontal", "Vertical"}
local strip_options_data = {SpriteSheetType.HORIZONTAL, SpriteSheetType.VERTICAL}
local previous_dir

-- Updates filesystem selected directory and saves as previous dir
local function UpdateDir(plugin, data)
    -- Get parent folder of save data
    parent_folder = app.fs.filePath(data.dlg_directory)

    -- Save last selected directory to preferences
    plugin.preferences.lastdir = parent_folder
    previous_dir = parent_folder
end

-- Export function
local function Export(data)
    -- Check directory
    if previous_dir == "" then
        app.alert("No Directory Selected")
        data:close()
    end

    -- Make parent export folder
    exportFolderName = data.dlg_export_folder
    app.fs.makeDirectory(previous_dir .. "/" .. exportFolderName)

    -- Tag filter
    local export_tag_list
    if data.dlg_tag == "All Tags" then
        export_tag_list = active_sprite.tags
    else
        for i, tag in ipairs(active_sprite.tags) do
            if data.dlg_tag == tag.name then
                export_tag_list = {tag}
            end
        end
    end

    -- Filter strip direction
    local strip_direction = data.dlg_strip_direction == "Horizontal" and 1 or 2

    -- Export selected tags
    for i, tag in ipairs(export_tag_list) do
        local fileName = previous_dir .. '/' .. exportFolderName .. '/' .. tag.name
        app.command.ExportSpriteSheet {
            ui = false,
            type = strip_options_data[strip_direction],
            textureFilename = fileName .. '.png',
            tag = tag.name,
            listLayers = false,
            listTags = false,
            listSlices = false
        }
    end
end

-- Dialog Show Function
local function ShowDialog(plugin)
    -- Check active layer
    active_layer = app.activeLayer
    if not active_layer then
        app.alert("No Active Layer")
        return
    end

    -- Check active sprite
    active_sprite = app.activeSprite
    if not active_sprite then
        app.alert("No Sprite")
        return
    end

    -- Remove spaces from sprite name
    local sprite_name = string.gsub(active_layer.name, "%s+", "")

    -- Check if project have tags
    if #active_sprite.tags == 0 then
        app.alert("No Tags to Export")
        return
    end
    local tag_options = {"All Tags"};

    -- Get all avilable tags
    for i, tag in ipairs(active_sprite.tags) do
        tag_options[i + 1] = tag.name;
    end

    dlg = Dialog("Export Layer Tags")
    dlg:separator{
        id = "dlg_settings_separator",
        text = "Settings"
    }:combobox{
        id = "dlg_tag",
        label = "Tags",
        options = tag_options
    }:combobox{
        id = "dlg_strip_direction",
        label = "Strip Direction",
        options = strip_options
    }:entry{
        id = "dlg_export_folder",
        label = "Folder Name",
        text = sprite_name,
        focus = true
    }:file{
        id = "dlg_directory",
        label = "Select Directory",
        title = "Select Directory",
        open = false,
        save = true,
        filename = sprite_name,
        entry = true,
        filetypes = {"folder"},
        onchange = function()
            UpdateDir(plugin, dlg.data)
        end
    }:separator{
        id = "dlg_export_separator",
        text = "Export"
    }:button{
        id = "dlg_ok",
        text = "&Export",
        onclick = function()
            Export(dlg.data)
            dlg:close()
        end
    }:button{
        text = "&Cancel"
    }:show{
        wait = false
    }
end

function init(plugin)
    -- Check if we have previous directory saved
    if plugin.preferences.lastdir == nil then
        plugin.preferences.lastdir = ""
    end

    -- Cache previous directory
    previous_dir = plugin.preferences.lastdir

    -- Register command
    plugin:newCommand{
        id = "excalith-export-tags",
        title = "Export Tags",
        group = "file_export",
        onclick = function()
            ShowDialog(plugin)
        end
    }
end

function exit(plugin)
end
