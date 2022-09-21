-- Local Variables
local lastDirectory

-- Hides layer visibilities and returns layer visibility table
function HideLayers(spr)
    local layerData = {} -- Save visibility status of each layer here.

    for i, layer in ipairs(spr.layers) do
        -- Recursive for layer groups
        if layer.isGroup then             
            layerData[i] = HideLayers(layer)
        else
            layerData[i] = layer.isVisible
            -- Set layer visible if active layer is current iteration
            layer.isVisible = layer.name == app.activeLayer.name
        end
    end

    return layerData
end

-- Restores layer visibilities
function ShowLayers(sprite, data)
    for i, layer in ipairs(sprite.layers) do
        if layer.isGroup then
            -- Recursive for layer groups
            ShowLayers(layer, data[i])
        else
            layer.isVisible = data[i]
        end
    end
end

-- Returns exportable tags
function GetTagList(sprite, selectedTag)
    local exportTagList
    if selectedTag == "All Tags" then
        exportTagList = activeSprite.tags
    else
        for i, tag in ipairs(activeSprite.tags) do
            if selectedTag == tag.name then
                exportTagList = {tag}
            end
        end
    end

    return exportTagList
end

-- Returns strip direction
function GetStripDirection(stripDir)
    stripOptionsData = {SpriteSheetType.HORIZONTAL, SpriteSheetType.VERTICAL}
    stripDirection = stripDir == "Horizontal" and 1 or 2
    return stripOptionsData[stripDirection]
end

-- Export function
function ExportSpriteSheet(data)
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
    local exportTagList = GetTagList(activeSprite, data.d_tag)

    -- If Export Only Selected Layer selected, hide inactive layers
    local layerData
    if data.d_export_layer then
        layerData = HideLayers(activeSprite)
    end

    -- Export selected tags
    for i, tag in ipairs(exportTagList) do
        fileName = lastDirectory .. '/' .. exportFolderName .. '/' .. tag.name
        app.command.ExportSpriteSheet {
            ui = false,
            type = GetStripDirection(data.d_strip_dir),
            textureFilename = fileName .. '.png',
            tag = tag.name,
            listLayers = false,
            listTags = false,
            listSlices = false
        }
    end

    -- If Export Only Selected Layer selected, restore layer visibilities
    if data.d_export_layer then
        layerData = ShowLayers(activeSprite, layerData)
    end
end

-- Dialog show function
function ShowDialog(plugin)
    -- Check active sprite
    activeSprite = app.activeSprite
    if not activeSprite then
        app.alert("No Sprite")
        return
    end

    -- Check active layer
    activeLayer = app.activeLayer
    if not activeLayer then
        app.alert("No Active Layer")
        return
    end

    -- Check if project have tags
    if #activeSprite.tags == 0 then
        app.alert("No Tags to Export")
        return
    end

    -- Remove spaces from sprite name
    spriteName = string.gsub(activeLayer.name, "%s+", "")


    -- Get all avilable tags
    tagOptions = {"All Tags"};
    for i, tag in ipairs(activeSprite.tags) do
        tagOptions[i + 1] = tag.name;
    end

    dlg = Dialog("Export Tags")
    dlg:combobox{
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
        options = {"Horizontal", "Vertical"},
        onchange = function()
            plugin.preferences.stripDirection = dlg.data.d_strip_dir
        end
    }:check{
        id = "d_export_layer",
        label = "Only Selected Layer",
        selected = plugin.preferences.onlySelectedLayer,
        onclick = function()
            plugin.preferences.onlySelectedLayer = dlg.data.d_export_layer
        end
    }:separator{
        text = ""
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
        text = ""
    }:button{
        id = "d_btn_export",
        text = "&Export",
        onclick = function()
            ExportSpriteSheet(dlg.data)
            dlg:close()
        end
    }:button{
        text = "&Cancel"
    }:show{
        wait = false
    }
end

-- Plugin initialize
function init(plugin)
    -- Check if we have previous directory prefs
    if plugin.preferences.lastdir == nil then
        plugin.preferences.lastdir = ""
    end

    -- Check previous selected tag prefs
    if plugin.preferences.selectedTag == nil then
        plugin.preferences.selectedTag = "All Tags"
    end

    -- Check previous selected strip direction prefs
    if plugin.preferences.stripDirection == nil then
        plugin.preferences.stripDirection = "Horizontal"
    end

    -- Check previous export only selected layer prefs
    if plugin.preferences.onlySelectedLayer == nil then
        plugin.preferences.onlySelectedLayer = false
    end

    -- Cache previous directory
    lastDirectory = plugin.preferences.lastdir

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

-- Plugin exit
function exit(plugin)
end
