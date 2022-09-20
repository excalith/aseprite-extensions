function init(plugin)
    local status = {"Default", "Complete", "In-Progress", "Not Started"}
    local colors = {Color {
        r = 0,
        g = 0,
        b = 0,
        a = 0
    }, Color {
        r = 155,
        g = 200,
        b = 0,
        a = 155
    }, Color {
        r = 10,
        g = 110,
        b = 225,
        a = 155
    }, Color {
        r = 155,
        g = 0,
        b = 0,
        a = 155
    }}

    -- Index Of
    function IndexOf(array, value)
        for i, v in ipairs(array) do
            if v == value then
                return i
            end
        end
        return nil
    end

    -- Change Layer Color Function
    local function ChangeLayerColor(data)
        -- Check Active Layer
        if not app.activeLayer then
            app.alert("No Active Layer")
            return
        end

        -- Get Index Of Status Selection
        status_index = IndexOf(status, data.dlg_status)

        -- Apply Color To Layer
        app.activeLayer.color = colors[status_index]
    end

    local function ShowDialogue()
        dlg = Dialog("Layer Flag")
        dlg:combobox{
            id = "dlg_status",
            label = "Status",
            options = status
        }:button{
            id = "dlg_ok",
            text = "&Apply",
            onclick = function()
                ChangeLayerColor(dlg.data)
            end
        }:button{
            text = "&Close"
        }:show{
            wait = false
        }
    end

    plugin:newCommand{
        id = "Status",
        title = "Set Layer Status",
        group = "layer_popup_properties",
        onclick = ShowDialogue
    }
end

function exit(plugin)
end
