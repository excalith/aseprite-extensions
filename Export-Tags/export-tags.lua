-- Local Variables
local stripOptions = {"Horizontal", "Vertical"}
local stripOptionsData = {SpriteSheetType.HORIZONTAL, SpriteSheetType.VERTICAL}
local lastDirectory

-- Export function
function export_tags(data)
    -- Check directory
    if lastDirectory == "" then
        app.alert("No Directory Selected")
        data:close()
    end

    -- Make parent export folder
    exportFolderName = data.d_export_folder
    app.fs.makeDirectory(lastDirectory .. "/" .. exportFolderName)

    -- Tag filter
    activeSprite = app.activeSprite
    local exportTagList
    if data.d_tag == "All Tags" then
        exportTagList = activeSprite.tags
    else
        for i, tag in ipairs(activeSprite.tags) do
            if data.d_tag == tag.name then
                exportTagList = {tag}
            end
        end
    end

    -- Filter strip direction
    stripDirection = data.d_strip_dir == "Horizontal" and 1 or 2

    -- Export selected tags
    for i, tag in ipairs(exportTagList) do
        fileName = lastDirectory .. '/' .. exportFolderName .. '/' .. tag.name
        app.command.ExportSpriteSheet {
            ui = false,
            type = stripOptionsData[stripDirection],
            textureFilename = fileName .. '.png',
            tag = tag.name,
            listLayers = false,
            listTags = false,
            listSlices = false
        }
    end
end

-- Dialog show function
function show_dialog(plugin)
    -- Check active layer
    activeLayer = app.activeLayer
    if not activeLayer then
        app.alert("No Active Layer")
        return
    end

    -- Check active sprite
    activeSprite = app.activeSprite
    if not activeSprite then
        app.alert("No Sprite")
        return
    end

    -- Remove spaces from sprite name
    spriteName = string.gsub(activeLayer.name, "%s+", "")

    -- Check if project have tags
    if #activeSprite.tags == 0 then
        app.alert("No Tags to Export")
        return
    end
    tagOptions = {"All Tags"};

    -- Get all avilable tags
    for i, tag in ipairs(activeSprite.tags) do
        tagOptions[i + 1] = tag.name;
    end

    dlg = Dialog("Export Tags")
    dlg:separator{
        text = "Settings"
    }:combobox{
        id = "d_tag",
        label = "Tags",
        option = plugin.preferences.selectedTag,
        options = tagOptions,
        onchange = function() 
            plugin.preferences.selectedTag = dlg.data.d_tag
        end
    }:combobox{
        id = "d_strip_dir",
        label = "Strip Direction",
        option = plugin.preferences.stripDirection,
        options = stripOptions,
        onchange = function() 
            plugin.preferences.stripDirection = dlg.data.d_strip_dir
        end
    }:entry{
        id = "d_export_folder",
        label = "Folder Name",
        text = spriteName,
        focus = true
    }:file{
        id = "d_directory",
        label = "Project Directory",
        title = "Select A Project Directory",
        open = false,
        save = true,
        filename = spriteName,
        entry = true,
        filetypes = {},
        onchange = function()
            -- Get parent folder of save data
            parentFolder = app.fs.filePath(dlg.data.d_directory)

            -- Save last selected directory to preferences
            plugin.preferences.lastdir = parentFolder
            lastDirectory = parentFolder
        end
    }:separator{
        text = "Export"
    }:button{
        id = "d_btn_export",
        text = "&Export",
        onclick = function()
            export_tags(dlg.data)
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

    -- Check previous selected tag saved
    if plugin.preferences.selectedTag == nil then
        plugin.preferences.selectedTag = "All Tags"
    end

    -- Check previous selected strip direction saved
    if plugin.preferences.stripDirection == nil then
        plugin.preferences.stripDirection = "Horizontal"
    end

    -- Cache previous directory
    lastDirectory = plugin.preferences.lastdir

    -- Register command
    plugin:newCommand{
        id = "excalith-export-tags",
        title = "Export Tags",
        group = "file_export",
        onclick = function()
            show_dialog(plugin)
        end
    }
end

function exit(plugin)
end
