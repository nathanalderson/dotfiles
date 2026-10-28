local workspaceSwitch = { debug = false }
local event = hs.eventtap.event
local types = event.types
local masks = event.rawFlagMasks
local tap
local swallowedKeys = {}
local swipeTask
local executable
local swipeVelocity = 20
local pendingDirections = {}
local cachedGestures = {}
local prediction
local moveExecutable
local refocusTimer
-- macOS keeps reporting the previous space for a moment after a switch, so rapid
-- repeats route from a predicted space (as WhichSpace does) and reuse fresh events.
local predictionLifetime = 1
local gestureLifetime = 1

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

local function buildHelper(name)
    local source = hs.configdir .. "/" .. name .. ".c"
    local buildDirectory = hs.configdir .. "/.build"
    local executable = buildDirectory .. "/" .. name
    local sourceInfo = assert(hs.fs.attributes(source), "Missing " .. name .. " source")
    local executableInfo = hs.fs.attributes(executable)
    if not executableInfo or executableInfo.modification < sourceInfo.modification then
        assert(hs.fs.attributes(buildDirectory) or hs.fs.mkdir(buildDirectory))
        local output, success = hs.execute("/usr/bin/clang -O2 -Wall -Wextra -Werror "
            .. "-framework ApplicationServices -framework AppKit " .. shellQuote(source)
            .. " -o " .. shellQuote(executable) .. " 2>&1")
        assert(success, "Could not build " .. name .. " helper (requires Xcode Command Line Tools): "
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

local function now()
    return hs.timer.absoluteTime() / 1e9
end

local function fail(message)
    hs.printf("Workspace swipe failed: %s", message)
    hs.alert.show(message)
    pendingDirections = {}
    prediction = nil
end

local function freshPrediction()
    return prediction and now() - prediction.at < predictionLifetime and prediction or nil
end

local function targetSpace(direction)
    local activeSpace = hs.spaces.focusedSpace()
    if not activeSpace then
        return nil
    end
    local display = hs.spaces.spaceDisplay(activeSpace)
    local spaces = display and hs.spaces.spacesForScreen(display)
    if not spaces then
        return nil
    end
    local current = activeSpace
    if freshPrediction() then
        for _, space in ipairs(spaces) do
            if space == prediction.space then
                current = space
                break
            end
        end
    end
    local offset = direction == "right" and 1 or -1
    for index, space in ipairs(spaces) do
        if space == current then
            return spaces[index + offset]
        end
    end
    return nil
end

local drain

local function generate(direction)
    swipeTask = hs.task.new(executable, function(exitCode, stdout, stderr)
        swipeTask = nil
        if exitCode ~= 0 then
            fail(stderr ~= "" and stderr or ("Workspace swipe helper exited with " .. exitCode))
            return
        end
        local success, message = pcall(function()
            local serialized = assert(hs.plist.readString(stdout), "Invalid workspace swipe payload")
            assert(#serialized == 6, "Expected six workspace swipe events")
            local gestures = {}
            for index, data in ipairs(serialized) do
                gestures[index] = assert(event.newEventFromData(data), "Invalid workspace swipe event")
            end
            cachedGestures[direction] = { gestures = gestures, at = now() }
        end)
        if not success then
            fail(message)
            return
        end
        drain()
    end, { direction, tostring(swipeVelocity) })
    if not swipeTask or not swipeTask:start() then
        swipeTask = nil
        fail("Could not start workspace swipe helper")
        return false
    end
    return true
end

drain = function()
    while pendingDirections[1] do
        local direction = pendingDirections[1]
        local cached = cachedGestures[direction]
        if not cached or now() - cached.at >= gestureLifetime then
            return swipeTask ~= nil or generate(direction)
        end
        table.remove(pendingDirections, 1)
        for _, gestureEvent in ipairs(cached.gestures) do
            gestureEvent:timestamp(hs.timer.absoluteTime()):post()
        end
    end
    return true
end

-- hs.spaces.moveWindowToSpace silently no-ops on current macOS, hence the SkyLight helper.
local function refocus(window, space, attempts)
    if refocusTimer then
        refocusTimer:stop()
    end
    refocusTimer = hs.timer.doAfter(0.05, function()
        refocusTimer = nil
        if hs.spaces.focusedSpace() == space then
            window:focus()
        elseif attempts < 100 then
            refocus(window, space, attempts + 1)
        end
    end)
end

function workspaceSwitch.switch(direction, carryWindow)
    assert(direction == "left" or direction == "right", "Direction must be left or right")
    local target = targetSpace(direction)
    if not target then
        return false
    end
    local window
    if carryWindow then
        -- Rapid repeats keep carrying the window moved by the previous step.
        local previous = freshPrediction()
        window = previous and previous.window or hs.window.focusedWindow()
        if window and window:isFullScreen() then
            window = nil
        end
        if window then
            moveExecutable = moveExecutable or buildHelper("workspace_move")
            local output, success = hs.execute(moveExecutable .. " " .. window:id() .. " " .. target .. " 2>&1")
            if not success then
                fail("Could not move window: " .. output)
                return false
            end
        end
    end
    executable = executable or buildHelper("workspace_swipe")
    prediction = { space = target, at = now(), window = window }
    if window then
        refocus(window, target, 0)
    end
    pendingDirections[#pendingDirections + 1] = direction
    return drain()
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
    executable = buildHelper("workspace_swipe")
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
        local shouldSwitch = chordMatched and not flags.ctrl
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
        if keyEvent:getProperty(event.properties.keyboardEventAutorepeat) == 0 then
            workspaceSwitch.switch(direction, flags.shift)
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