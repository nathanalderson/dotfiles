local dragScroll = {}
local event = hs.eventtap.event
local types = event.types
local properties = event.properties
local syntheticTag = 0x44534352
local tap
local gesture

local defaults = {
    sensitivity = 1.5,
    acceleration = 0.4,
    referenceSpeed = 500,
    maxMultiplier = 4,
    threshold = 4,
    horizontal = true,
    invert = false,
}

local function truncate(value)
    return value < 0 and math.ceil(value) or math.floor(value)
end

function dragScroll.stop()
    if tap then
        tap:stop()
        tap = nil
    end
    gesture = nil
end

function dragScroll.start(options)
    local settings = {}
    for key, value in pairs(defaults) do
        settings[key] = value
    end
    for key, value in pairs(options or {}) do
        assert(defaults[key] ~= nil, "Unknown dragScroll setting: " .. key)
        settings[key] = value
    end
    for _, key in ipairs({ "sensitivity", "acceleration", "threshold" }) do
        assert(type(settings[key]) == "number" and settings[key] >= 0,
            key .. " must be a nonnegative number")
    end
    assert(type(settings.referenceSpeed) == "number" and settings.referenceSpeed > 0,
        "referenceSpeed must be positive")
    assert(type(settings.maxMultiplier) == "number" and settings.maxMultiplier >= 1,
        "maxMultiplier must be at least 1")
    assert(type(settings.horizontal) == "boolean" and type(settings.invert) == "boolean",
        "horizontal and invert must be booleans")

    dragScroll.stop()
    tap = hs.eventtap.new({ types.rightMouseDown, types.rightMouseDragged, types.rightMouseUp },
        function(mouseEvent)
            if mouseEvent:getProperty(properties.eventSourceUserData) == syntheticTag then
                return false
            end

            local eventType = mouseEvent:getType()
            if eventType == types.rightMouseDown then
                gesture = {
                    down = mouseEvent:copy(),
                    anchor = mouseEvent:location(),
                    lastTime = hs.timer.absoluteTime(),
                    distanceX = 0,
                    distanceY = 0,
                    remainderX = 0,
                    remainderY = 0,
                    scrolling = false,
                }
                return true
            end

            if not gesture then
                return false
            end

            if eventType == types.rightMouseUp then
                local finished = gesture
                gesture = nil
                if not finished.scrolling then
                    local down = finished.down:location(finished.anchor)
                        :timestamp(hs.timer.absoluteTime())
                        :setProperty(properties.eventSourceUserData, syntheticTag)
                    local up = mouseEvent:copy():location(finished.anchor)
                        :setProperty(properties.eventSourceUserData, syntheticTag)
                    return true, { down, up }
                end
                return true
            end

            local deltaX = mouseEvent:getProperty(properties.mouseEventDeltaX)
            local deltaY = mouseEvent:getProperty(properties.mouseEventDeltaY)
            local now = hs.timer.absoluteTime()
            local elapsed = math.max((now - gesture.lastTime) / 1e9, 0.001)
            gesture.lastTime = now
            hs.mouse.absolutePosition(gesture.anchor)

            if not gesture.scrolling then
                gesture.distanceX = gesture.distanceX + deltaX
                gesture.distanceY = gesture.distanceY + deltaY
                local distance = math.sqrt(gesture.distanceX ^ 2 + gesture.distanceY ^ 2)
                if distance < settings.threshold or distance == 0 then
                    return true
                end
                gesture.scrolling = true
            end

            local speed = math.sqrt(deltaX ^ 2 + deltaY ^ 2) / elapsed
            local multiplier = math.min(settings.maxMultiplier,
                1 + settings.acceleration * speed / settings.referenceSpeed)
            local gain = settings.sensitivity * multiplier * (settings.invert and -1 or 1)
            gesture.remainderX = gesture.remainderX + (settings.horizontal and deltaX * gain or 0)
            gesture.remainderY = gesture.remainderY + deltaY * gain
            local scrollX = truncate(gesture.remainderX)
            local scrollY = truncate(gesture.remainderY)
            gesture.remainderX = gesture.remainderX - scrollX
            gesture.remainderY = gesture.remainderY - scrollY

            if scrollX == 0 and scrollY == 0 then
                return true
            end
            return true, { event.newScrollEvent({ scrollX, scrollY }, {}, "pixel") }
        end)
    tap:start()
    return dragScroll
end

return dragScroll