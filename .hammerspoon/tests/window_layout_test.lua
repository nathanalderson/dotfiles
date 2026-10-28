local function run(options)
    local spaces = {}
    for number = 1, options.count or 4 do
        spaces[#spaces + 1] = 100 + number
    end
    if options.fullscreen then
        table.insert(spaces, 2, 900)
    end
    local current = 100 + options.original
    local actions, timers, alerts = {}, {}, {}
    local busy = options.busy
    local failed = false
    local applied = 0
    local mockHs = {
        window = { filter = {
            new = function()
                return { keepActive = function(self) return self end }
            end,
        } },
        screen = {
            allScreens = function() return { 1, 2 } end,
            primaryScreen = function() return 1 end,
        },
        spaces = {
            focusedSpace = function() return current end,
            screensHaveSeparateSpaces = function() return false end,
            spacesForScreen = function() return spaces end,
            spaceType = function(space) return space == 900 and "fullscreen" or "user" end,
        },
        alert = { show = function(message) alerts[#alerts + 1] = message end },
        timer = { doAfter = function(_, callback) timers[#timers + 1] = callback end },
        eventtap = { keyStroke = function(modifiers, key, delay)
            assert(modifiers[1] == "ctrl" and delay == 0)
            actions[#actions + 1] = "^" .. key
            current = 100 + tonumber(key)
        end },
    }
    local switch = { switch = function(direction)
        if busy then
            busy = false
            return false
        end
        if options.fail and not failed then
            failed = true
            error("Swipe failed")
        end
        actions[#actions + 1] = direction
        if not options.timeout then
            for index, space in ipairs(spaces) do
                if space == current then
                    current = spaces[index + (direction == "right" and 1 or -1)]
                    break
                end
            end
        end
        return true
    end }
    local environment = setmetatable({
        hs = mockHs,
        require = function(name)
            assert(name == "workspace_switch")
            return switch
        end,
    }, { __index = _G })
    local chunk
    if setfenv then
        chunk = setfenv(assert(loadfile(".hammerspoon/window_layout.lua")), environment)
    else
        chunk = assert(loadfile(".hammerspoon/window_layout.lua", "t", environment))
    end
    local layout = chunk()
    layout.apply = function()
        applied = applied + 1
        assert(current == 100 + options.original)
        return true
    end
    assert(layout.applyAllSpaces())
    if #timers > 0 then
        assert(not layout.applyAllSpaces(), "Concurrent sweeps must be rejected")
    end
    local iterations = 0
    while #timers > 0 do
        iterations = iterations + 1
        assert(iterations < 500, "Sweep did not finish")
        table.remove(timers, 1)()
    end
    assert(current == 100 + options.original, "Must restore the original desktop")
    assert(table.concat(actions, ",") == options.expected, table.concat(actions, ","))
    if options.fail or options.timeout then
        assert(applied == 0 and #alerts == 1)
        assert(alerts[1]:find(options.fail and "Swipe failed" or "Timed out", 1, true))
    else
        assert(applied == 1 and #alerts == 0)
    end
    assert(layout.applyAllSpaces(), "Sweep state must be cleared")
end

run({ original = 3, expected = "^1,right,right,right,^3" })
run({ original = 2, expected = "left,right,right,right,^2" })
run({ original = 1, expected = "right,right,right,^1" })
run({ original = 4, expected = "^1,right,right,right" })
run({ original = 1, count = 1, expected = "" })
run({ original = 2, busy = true, expected = "left,right,right,right,^2" })
run({ original = 3, fullscreen = true, expected = "^1,^2,right,right,^3" })
run({ original = 3, count = 11, expected = "^1,right,right,right,right,right,right,right,right,^3" })
run({ original = 2, fail = true, expected = "" })
run({ original = 3, fail = true, expected = "^1,^3" })
run({ original = 3, timeout = true, expected = "^1,right,^3" })

print("Window layout tests passed")
