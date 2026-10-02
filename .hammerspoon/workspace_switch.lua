local workspaceSwitch = { debug = false }
local event = hs.eventtap.event
local types = event.types
local masks = event.rawFlagMasks
local tap
local swallowedKeys = {}
local swipeTask
local executable
local swipeVelocity = 20

local directions = {
    [hs.keycodes.map.left] = "left",
    [hs.keycodes.map.right] = "right",
}

local function hasFlag(flags, mask)
    return flags % (mask * 2) >= mask
end

local function shellQuote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function buildHelper()
    local source = hs.configdir .. "/workspace_swipe.c"
    local buildDirectory = hs.configdir .. "/.build"
    local executable = buildDirectory .. "/workspace_swipe"
    local sourceInfo = assert(hs.fs.attributes(source), "Missing workspace swipe source")
    local executableInfo = hs.fs.attributes(executable)
    if not executableInfo or executableInfo.modification < sourceInfo.modification then
        assert(hs.fs.attributes(buildDirectory) or hs.fs.mkdir(buildDirectory))
        local output, success = hs.execute("/usr/bin/clang -O2 -Wall -Wextra -Werror "
            .. "-framework ApplicationServices " .. shellQuote(source)
            .. " -o " .. shellQuote(executable) .. " 2>&1")
        assert(success, "Could not build workspace swipe helper (requires Xcode Command Line Tools): "
            .. output)
    end
    return executable
end

function workspaceSwitch.stop()
    if tap then
        tap:stop()
        tap = nil
    end
    swallowedKeys = {}
end

local function canSwitch(direction)
    local activeSpace = hs.spaces.focusedSpace()
    if not activeSpace then
        return false
    end
    local display = hs.spaces.spaceDisplay(activeSpace)
    local spaces = display and hs.spaces.spacesForScreen(display)
    if not spaces then
        return false
    end
    local offset = direction == "right" and 1 or -1
    for index, space in ipairs(spaces) do
        if space == activeSpace then
            return spaces[index + offset] ~= nil
        end
    end
    return false
end

function workspaceSwitch.switch(direction)
    assert(direction == "left" or direction == "right", "Direction must be left or right")
    if swipeTask or not canSwitch(direction) then
        return false
    end
    executable = executable or buildHelper()
    swipeTask = hs.task.new(executable, function(exitCode, stdout, stderr)
        swipeTask = nil
        if exitCode ~= 0 then
            hs.printf("Workspace swipe failed (%d): %s", exitCode, stderr)
            hs.alert.show(stderr ~= "" and stderr or "Workspace swipe failed; check Hammerspoon Console")
            return
        end
        local success, message = pcall(function()
            local serialized = assert(hs.plist.readString(stdout), "Invalid workspace swipe payload")
            assert(#serialized == 6, "Expected six workspace swipe events")
            local gestures = {}
            for index, data in ipairs(serialized) do
                gestures[index] = assert(event.newEventFromData(data), "Invalid workspace swipe event")
            end
            if not canSwitch(direction) then
                return
            end
            for _, gestureEvent in ipairs(gestures) do
                gestureEvent:timestamp(hs.timer.absoluteTime()):post()
            end
        end)
        if not success then
            hs.printf("Workspace swipe failed: %s", message)
            hs.alert.show(message)
        end
    end, { direction, tostring(swipeVelocity) })
    if not swipeTask or not swipeTask:start() then
        swipeTask = nil
        hs.alert.show("Could not start workspace swipe helper")
        return false
    end
    return true
end

function workspaceSwitch.start(options)
    options = options or {}
    for key in pairs(options) do
        assert(key == "velocity", "Unknown workspaceSwitch setting: " .. key)
    end
    local velocity = options.velocity == nil and 20 or options.velocity
    assert(type(velocity) == "number" and velocity > 0 and velocity < math.huge,
        "velocity must be a positive finite number")
    workspaceSwitch.stop()
    swipeVelocity = velocity
    executable = buildHelper()
    tap = hs.eventtap.new({ types.keyDown, types.keyUp }, function(keyEvent)
        local keyCode = keyEvent:getKeyCode()
        local direction = directions[keyCode]
        if not direction then
            return false
        end

        if keyEvent:getType() == types.keyUp then
            local swallowed = swallowedKeys[keyCode] or false
            swallowedKeys[keyCode] = nil
            return swallowed
        end

        local flags = keyEvent:getFlags()
        local rawFlags = keyEvent:rawFlags()
        local bothCommands = hasFlag(rawFlags, masks.deviceLeftCommand)
            and hasFlag(rawFlags, masks.deviceRightCommand)
        local remappedCommands = hasFlag(rawFlags, masks.deviceLeftAlternate)
            and hasFlag(rawFlags, masks.deviceRightCommand)
            and not hasFlag(rawFlags, masks.deviceLeftCommand)
            and not hasFlag(rawFlags, masks.deviceRightAlternate)
        local chordMatched = (bothCommands and not flags.alt) or remappedCommands
        local shouldSwitch = chordMatched and not flags.ctrl and not flags.shift
        if workspaceSwitch.debug and keyEvent:getProperty(event.properties.keyboardEventAutorepeat) == 0 then
            local message = string.format("Workspace %s: %s; raw=0x%x; modifiers=%s",
                direction, shouldSwitch and "chord detected" or "chord not detected",
                rawFlags, hs.inspect(flags))
            hs.printf("%s", message)
            hs.alert.show(message, 3)
        end
        if not shouldSwitch then
            return swallowedKeys[keyCode] or false
        end

        swallowedKeys[keyCode] = true
        if keyEvent:getProperty(event.properties.keyboardEventAutorepeat) == 0 and not swipeTask then
            workspaceSwitch.switch(direction)
        end
        return true
    end)
    tap:start()
    if workspaceSwitch.debug then
        hs.alert.show("Workspace switch handler loaded", 2)
    end
    return workspaceSwitch
end

return workspaceSwitch