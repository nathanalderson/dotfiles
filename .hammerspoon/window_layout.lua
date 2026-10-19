local windowLayout = {}
local workspaceSwitch = require("workspace_switch")
local hotkey
local displayWatcher
local displayTimer
local sweeping = false
hs.window.filter.forceRefreshOnSpaceChange = true
local windowFilter = hs.window.filter.new({ "Slack", "Discord", "Code" }):keepActive()

local layouts = {
    ["com.tinyspeck.slackmacgap"] = { x = 614 / 2304, y = 243 / 1296, w = 1632 / 2304, h = 985 / 1296 },
    ["com.hnc.Discord"] = { x = 43 / 2304, y = 32 / 1296, w = 1719 / 2304, h = 1005 / 1296 },
}

function windowLayout.apply()
    local screens = hs.screen.allScreens()
    if #screens < 2 then
        hs.alert.show("Window layout needs a second display")
        return false
    end

    local target = screens[1]
    for _, screen in ipairs(screens) do
        if screen:frame().x > target:frame().x then
            target = screen
        end
    end

    local firstDesktop
    for _, space in ipairs(hs.spaces.spacesForScreen(target) or {}) do
        if hs.spaces.spaceType(space) == "user" then
            firstDesktop = space
            break
        end
    end
    if not firstDesktop then
        hs.alert.show("Could not find Desktop 1")
        return false
    end

    local screenFrame = target:frame()
    for _, window in ipairs(windowFilter:getWindows()) do
        local bundleID = window:application():bundleID()
        local layout = layouts[bundleID]
        local eligible = window:isStandard() and not window:isMinimized() and not window:isFullScreen()
        if bundleID == "com.microsoft.VSCode" and eligible then
            window:setFrame(screenFrame, 0)
        elseif layout and eligible then
            local onFirstDesktop = false
            for _, space in ipairs(hs.spaces.windowSpaces(window) or {}) do
                if space == firstDesktop then
                    onFirstDesktop = true
                    break
                end
            end
            if not onFirstDesktop then
                local success, message = hs.spaces.moveWindowToSpace(window, firstDesktop)
                if not success then
                    hs.alert.show("Could not move window to Desktop 1: " .. tostring(message))
                    return false
                end
            end
            window:setFrame({
                x = math.floor(screenFrame.x + layout.x * screenFrame.w + 0.5),
                y = math.floor(screenFrame.y + layout.y * screenFrame.h + 0.5),
                w = math.floor(layout.w * screenFrame.w + 0.5),
                h = math.floor(layout.h * screenFrame.h + 0.5),
            }, 0)
        end
    end
    return true
end

local function visitSpace(space, callback, desktopNumber)
    local attempts = 0
    local pendingSpace
    if desktopNumber and hs.spaces.focusedSpace() ~= space then
        local success, message = pcall(hs.eventtap.keyStroke, { "ctrl" }, tostring(desktopNumber), 0)
        if not success then
            callback(message)
            return
        end
        pendingSpace = space
    end
    local function waitForSpace()
        local current = hs.spaces.focusedSpace()
        if current == space then
            hs.timer.doAfter(0.15, callback)
            return
        elseif attempts >= 100 then
            callback("Timed out switching workspace")
            return
        end

        if not pendingSpace or current == pendingSpace then
            local success, message = pcall(function()
                local spaces = assert(hs.spaces.spacesForScreen(hs.screen.primaryScreen()))
                local currentIndex, targetIndex
                for index, candidate in ipairs(spaces) do
                    if candidate == current then
                        currentIndex = index
                    end
                    if candidate == space then
                        targetIndex = index
                    end
                end
                assert(currentIndex and targetIndex, "Workspace disappeared during layout")
                local offset = targetIndex > currentIndex and 1 or -1
                if workspaceSwitch.switch(offset == 1 and "right" or "left") then
                    pendingSpace = spaces[currentIndex + offset]
                end
            end)
            if not success then
                callback(message)
                return
            end
        end
        attempts = attempts + 1
        hs.timer.doAfter(0.05, waitForSpace)
    end
    waitForSpace()
end

function windowLayout.applyAllSpaces()
    if sweeping then
        return false
    end
    if #hs.screen.allScreens() < 2 then
        return windowLayout.apply()
    end
    if hs.spaces.screensHaveSeparateSpaces() then
        hs.alert.show("Workspace sweep requires linked display Spaces")
        return false
    end

    local original = hs.spaces.focusedSpace()
    local spaces, message = hs.spaces.spacesForScreen(hs.screen.primaryScreen())
    if not original or not spaces then
        hs.alert.show(message or "Could not read workspaces")
        return false
    end

    local desktops = {}
    local originalNumber
    for _, space in ipairs(spaces) do
        if hs.spaces.spaceType(space) == "user" then
            table.insert(desktops, space)
            if space == original then
                originalNumber = #desktops
            end
        end
    end
    if #desktops == 0 then
        hs.alert.show("Could not find any desktops")
        return false
    end

    local returnNumber = math.min(originalNumber or #desktops, 5)
    local returnSpace = desktops[returnNumber]
    local queue = {}
    for number, space in ipairs(desktops) do
        table.insert(queue, { space = space, desktopNumber = number == 1 and 1 or nil })
    end
    table.insert(queue, { space = returnSpace, desktopNumber = returnNumber })
    if returnSpace ~= original then
        table.insert(queue, { space = original })
    end
    sweeping = true

    local function fail(reason)
        local function finish(restoreError)
            sweeping = false
            hs.alert.show("Window layout failed: " .. tostring(reason)
                .. (restoreError and "; could not return: " .. tostring(restoreError) or ""))
        end
        visitSpace(returnSpace, function(restoreError)
            if restoreError or returnSpace == original then
                finish(restoreError)
            else
                visitSpace(original, finish)
            end
        end, returnNumber)
    end

    local index = 0
    local function advance(errorMessage)
        if errorMessage then
            fail(errorMessage)
            return
        end
        index = index + 1
        if queue[index] then
            local destination = queue[index]
            visitSpace(destination.space, advance, destination.desktopNumber)
        else
            local success, result = pcall(windowLayout.apply)
            if not success then
                fail(result)
            else
                sweeping = false
            end
        end
    end
    advance()
    return true
end

function windowLayout.start()
    if hotkey then
        hotkey:delete()
    end
    if displayWatcher then
        displayWatcher:stop()
    end
    if displayTimer then
        displayTimer:stop()
        displayTimer = nil
    end
    hotkey = hs.hotkey.bind({ "cmd" }, "F6", windowLayout.applyAllSpaces)

    local knownDisplays = {}
    for _, screen in ipairs(hs.screen.allScreens()) do
        knownDisplays[screen:getUUID()] = true
    end
    local connectionPending = false

    local function applyWhenReady()
        displayTimer = nil
        if #hs.screen.allScreens() < 2 then
            connectionPending = false
            return
        end
        if sweeping then
            displayTimer = hs.timer.doAfter(0.5, applyWhenReady)
            return
        end
        connectionPending = false
        windowLayout.applyAllSpaces()
    end

    displayWatcher = hs.screen.watcher.new(function()
        local connected = {}
        for _, screen in ipairs(hs.screen.allScreens()) do
            local uuid = screen:getUUID()
            connected[uuid] = true
            if not knownDisplays[uuid] then
                connectionPending = true
            end
        end
        knownDisplays = connected
        if displayTimer then
            displayTimer:stop()
            displayTimer = nil
        end
        if connectionPending then
            displayTimer = hs.timer.doAfter(2, applyWhenReady)
        end
    end):start()
end

return windowLayout