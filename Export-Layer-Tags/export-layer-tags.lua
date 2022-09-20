function init(plugin)
    -- Local Variables
    local active_layer
    local active_sprite
    local file_type_list = {""};
    local strip_options = {"Horizontal", "Vertical"}
    local strip_options_data = {SpriteSheetType.HORIZONTAL, SpriteSheetType.VERTICAL}

    -- Export Function
    local function Export(data)
        -- Check Directory
        if data.dlg_directory == "" then
            app.alert("No Directory Selected")
            data:close()
        end

        -- Fix For Directory Extension (no folder selection API yet)
        local path = data.dlg_directory:gsub("%.", "")

        -- Tag Filter
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

        -- Filter Strip Direction
        local strip_direction = data.dlg_strip_direction == "Horizontal" and 1 or 2

        -- Export Tags
        for i, tag in ipairs(export_tag_list) do
            local fileName = path .. '/' .. tag.name
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

    -- Main Function
    local function ShowDialogue()
        -- Check Active Layer
        active_layer = app.activeLayer
        if not active_layer then
            app.alert("No Active Layer")
            return
        end

        -- Check Active Sprite
        active_sprite = app.activeSprite
        if not active_sprite then
            app.alert("No Sprite")
            return
        end

        local sprite_name = string.gsub(active_layer.name, "%s+", "")

        -- Check Tags
        if #active_sprite.tags == 0 then
            app.alert("No Tags to Export")
            return
        end
        local tag_options = {"All Tags"};

        -- Get All Tags
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
        }:file{
            id = "dlg_directory",
            label = "Select Directory",
            title = "Output File",
            open = false,
            save = true,
            filename = sprite_name,
            entry = true,
            filetypes = file_type_list
        }:separator{
            id = "dlg_export_separator",
            text = "Export"
        }
        :button{
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

    plugin:newCommand{
        id = "ExportLayerTags",
        title = "Export Layer Tags",
        group = "layer_popup_properties",
        onclick = ShowDialogue
    }
end
