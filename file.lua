-- name : Digiline Drawer Controller (master_drawer_controller)
-- author : skylord
-- version : 1
-- How do versions work? Each "Task" completed => + 0.1; Each "Set of instructions" completed => + 1
-- Bugs to solve : Each time you send a command via button, the last image goes away

config = {
    ["DCPrefix"] = "DC";
    ["TubePrefix"] = "skylord:501_SendItem";
    ["maxTubeChannels"] = 7;
}

-- People authorised to use drawers
config.users = {
    ["skylord"] = true;
    ["skypro"] = true;
    ["MCLV"] = true;
}

-- People authorised to see logs
config.owners = {
    ["skylord"] = true;
}

config.tubesToSend = {
    ["chest"] = "skylord:501_ToSendChest";
    ["draw"] = "skylord:501_ToSendDrawer";
}

-- Basically shorter names to access frequently used stuff easily
config.alias = {
    ["dirt"] = "default:dirt";
    ["mulch"] = "bonemeal:mulch";
    ["light"] = "technic:dummy_light_source";
    ["fuel"] = "biofuel:fuel_can";
}

config.outMsg = {
    [1] = "Bad tube channel! (Tube channel cannot be greater than " .. config["maxTubeChannels"] .. ").";
    [2] = "Bad container type. Pick 'draw' or 'chest' instead.";
    [3] = "Item has been sent!"; -- Subjective to change while code is being run
    [4] = "User has sent item!"; -- Same as comment above
    [5] = "Please input an valid item!";
    [6] = "You are not authorised to see logs!";
}

-- Notice: ',' is always the 'seperator'
function splitString(str)
    if type(str) ~= "string" then
        error("splitString (function) : Parameter needs to be a string!")
    end

    local result = {}
    local current = ""
    local i = 1

    while true do
        local char = string.sub(str, i, i)

        if not char or char == "" then
            break
        end

        if char == "," then
            table.insert(result, current)
            current = ""
        else
            current = current .. char
        end

        i = i + 1
    end

    table.insert(result, current)
    return result
end

-- To alter label so you dont need terminal to see bad inputs
function sendOutResponse(text)
    digiline_send("screen", {
        {
            command = "replace",
            index = 12,
            element = "label",
            label = "Output: " .. text,
            X = 0.2, Y = 11.5
        }
    })
end

function logActions(text)
    print(text)
    table.insert(mem.logs, text)
end

function getAnItem(nameOfItem, channel, containerType)
    if tonumber(channel) > config["maxTubeChannels"] then
        logActions(config.outMsg[1])
        sendOutResponse(config.outMsg[1])
        return
    end

    if not config.tubesToSend[containerType] then
        logActions(config.outMsg[2])
        sendOutResponse(config.outMsg[2])
        return
    end

    local spacePos = string.find(nameOfItem, " ", 1, true)
    local itemBase, totalQty

    if spacePos then
        itemBase = string.sub(nameOfItem, 1, spacePos - 1)
        totalQty = tonumber(string.sub(nameOfItem, spacePos + 1))
    end

    if config.alias[itemBase] then
        itemBase = config.alias[itemBase]
    end

    if not totalQty then
        digiline_send(config["DCPrefix"] .. channel, nameOfItem)
        digiline_send(config["TubePrefix"], config.tubesToSend[containerType])
        logActions(config.outMsg[4])
        sendOutResponse(config.outMsg[3])
        return
    end

    -- dls doesnt send items over stack 99 by default, which is annoying
    -- Now I'm thinking if this would break pipes if an insane request was sent...
    local remaining = totalQty
    while remaining > 0 do
        local toSend = remaining
        if toSend > 99 then
            toSend = 99
        end

        local sendStr = itemBase .. " " .. toSend
        digiline_send(config["DCPrefix"] .. channel, sendStr)
        digiline_send(config["TubePrefix"], config.tubesToSend[containerType])
        remaining = remaining - toSend
    end

    logActions(config.outMsg[4])
    sendOutResponse(config.outMsg[3])
end

-- For some reason, touchscreens limit images to 2 per screen. Time to cheat some in
function cheatExtraImages()
    digiline_send("screen", {
        {
            command = "addimage",
            texture_name = "halo.png^[colorize:#050505",
            X = 0, Y = 11, W = 10.6, H = 1
        },
        { -- index 12
            command = "addlabel",
            label = "Output:",
            X = 0.2, Y = 11.5
        }
    })
end

function mainMenu()
    local controllerList = {}
    for i = 1, config["maxTubeChannels"] do
        controllerList[i] = config["DCPrefix"] .. i
    end
    digiline_send("screen", {
        {
            command = "clear"
        },
        {
            command = "add",
            element = "tabheader",
            X = 0,
            Y = 0,
            name = "tabheader",
            captions = {"Menu"--[[, "ShortCuts"]], "Logs"},
            current_tab = 1,
            transparent = false,
            draw_border = false,
        },
        {
            command = "set",
            locked = true,
            no_prepend = false,
            real_coordinates = true,
            fixed_size = false,
            width = 10.5,
            height = 12,
            focus = "txtInput",
        },
        {
            command = "addimage",
            texture_name = "halo.png^[colorize:#050505",
            X = -0.1, Y = 0, W = 10.6, H = 1
        },
        {
            command = "addtextlist",
            name = "DCInput",
            listelements = controllerList,
            transparent = false,
            selected_id = 1,
            X = 0.2, Y = 1.8, W = 3.3, H = 4.4
        },
        {
            command = "addtextlist",
            name = "ContainerInput",
            listelements = {[1] = "chest", [2] = "draw"},
            transparent = false,
            selected_id = 1,
            X = 7, Y = 1.8, W = 3.3, H = 4.4
        },
        {
            command = "addlabel",
            label = "Select DC",
            X = 0.7, Y = 1.6
        },
        {
            command = "addlabel",
            label = "Select container",
            X = 7.4, Y = 1.6
        },
        {
            command = "addfield",
            name = "txtInput",
            label = "",
            default = "",
            X = 2, Y = 7.5, W = 6.6, H = 0.8
        },
        {
            command = "addlabel",
            label = "technical name and quantity",
            X = 3.2, Y = 7.3
        },
        {
            command = "addbutton",
            name = "BtnSend",
            label = "Submit Request",
            X = 2, Y = 8.5, W = 6.6, H = 0.8
        },
        {
            command = "addimage",
            texture_name = "halo.png^[colorize:#050505",
            X = 0, Y = 9.6, W = 10.6, H = 1
        },
        { -- index 11
            command = "addlabel",
            label = "Authorised To Use This Screen: ",
            X = 0.2, Y = 10.1
        },

    })
    cheatExtraImages()
end

function displayLogs()
    local logsToDisplay = table.concat(mem.logs, "\n")
    digiline_send("screen", {
        {
            command = "clear"
        },
        {
            command = "set",
            locked = true,
            no_prepend = false,
            real_coordinates = true,
            fixed_size = false,
            width = 10.5,
            height = 10.5,
        },
        {
            command = "add",
            element = "tabheader",
            X = 0,
            Y = 0,
            name = "tabheader",
            captions = {"Menu"--[[, "ShortCuts"]], "Logs"},
            current_tab = 2,
            transparent = false,
            draw_border = false,
        },
        {
            command = "addimage",
            texture_name = "halo.png^[colorize:#050505",
            X = -0.1, Y = 0, W = 10.6, H = 1
        },
        {
            command = "addimage",
            texture_name = "halo.png^[colorize:#050505",
            X = 0, Y = 9.5, W = 10.6, H = 1
        },
        {
            command = "addlabel",
            label = "Logs",
            X = 4.7, Y = 0.5
        },
        {
            command = "addtextarea",
            name = "displayLogs",
            label = "", default = logsToDisplay,
            X = 0.2, Y = 1.2, W = 10.1, H = 7.5
        },
        {
            command = "addbutton_exit",
            name = "",
            label = "Exit",
            X = 3.7, Y = 9.6, W = 3, H = 0.8
        }
    })
end

local function parseCHG(str)
    local colonPos = string.find(str, ":", 1, true)
    if colonPos then
        return tonumber(string.sub(str, colonPos + 1))
    end
    return 1
end

if event.type == "program" then
    mem.dcIndex  = 1
    mem.conIndex = 1

    if not mem.logs then
        mem.logs = {}
    end
end

if event.type == "digiline" and event.channel == "screen" then
    if event.msg.tabheader == "1" then
        mainMenu()
    elseif event.msg.tabheader == "2" then
        if config.owners[event.msg.clicker] then
            displayLogs()
        else
            sendOutResponse(event.outMsg[6])
            return
        end
    end
    if not config.users[event.msg.clicker] then
        if event.msg.tabheader == "1" then
            digiline_send("screen", {
                {
                    command = "replace",
                    index = 11,
                    element = "label",
                    label = "Authorised To Use This Screen: False",
                    X = 0.2, Y = 10.1
                }
            })
        end
        logActions(event.msg.clicker .. " tried to use the program. Authorised : False")
        return
    else
        if event.msg.tabheader == "1" then
            digiline_send("screen", {
                {
                    command = "replace",
                    index = 11,
                    element = "label",
                    label = "Authorised To Use This Screen: True",
                    X = 0.2, Y = 10.1
                }
            })
        end
    end

    if event.msg.DCInput then
        mem.dcIndex = parseCHG(event.msg.DCInput)
    end

    if event.msg.ContainerInput then
        mem.conIndex = parseCHG(event.msg.ContainerInput)
    end

    if event.msg.BtnSend then
        local itemName = event.msg.txtInput
        local channel = mem.dcIndex
        local containers = {"chest", "draw"}
        local container = containers[mem.conIndex]

        if not itemName or itemName == "" then
            sendOutResponse(config.outMsg[5])
            return -- No need for print logs (nothing was sent)
        end

        config.outMsg[3] = itemName .. " has been sent to " .. container .. "!"
        config.outMsg[4] = itemName .. " has been sent to " .. container .. " by " .. event.msg.clicker
        getAnItem(itemName, channel, container)
    end
end

if event.type == "terminal" then
    local splitParameters = splitString(event.text)
    config.outMsg[3] = splitParameters[1] .. " has been sent to " .. splitParameters[3] .. "!"
    getAnItem(splitParameters[1], tonumber(splitParameters[2]), splitParameters[3])
end

-- DEBUG
-- if event.type == "digiline" then
--     print("\nChannel: " .. event.channel)
--     print("\nMsg type: " .. type(event.msg))
--     for k, v in pairs(event.msg) do
--         print("  [" .. tostring(k) .. "] = " .. tostring(v))
--     end
-- end

-- ! Test Data ! --
-- getAnItem("bonemeal:mulch 5", 1, "chest")
-- bonemeal:mulch 5,1,chest