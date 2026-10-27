local compose = {}
local types = hs.eventtap.event.types
local tap
local active = false
local composeDown = false
local buffer = ""
local swallowedKeys = {}

function compose.stop()
    if tap then
        tap:stop()
        tap = nil
    end
    active = false
    composeDown = false
    buffer = ""
    swallowedKeys = {}
end

function compose.start(sequences)
    assert(type(sequences) == "table", "Compose sequences must be a table")
    local prefixes = {}
    for sequence, output in pairs(sequences) do
        assert(type(sequence) == "string" and sequence ~= "",
            "Compose sequences must be nonempty strings")
        assert(type(output) == "string", "Compose output must be a string for " .. sequence)
        for length = 1, #sequence - 1 do
            prefixes[sequence:sub(1, length)] = true
        end
    end
    for prefix in pairs(prefixes) do
        assert(sequences[prefix] == nil, "Compose sequence is also a prefix: " .. prefix)
    end

    compose.stop()
    tap = hs.eventtap.new({ types.keyDown, types.keyUp }, function(keyEvent)
        local keyCode = keyEvent:getKeyCode()
        local isDown = keyEvent:getType() == types.keyDown
        if keyCode == hs.keycodes.map.f20 then
            if isDown then
                if not composeDown then
                    active = true
                    buffer = ""
                end
            end
            composeDown = isDown
            return true
        end

        if not isDown then
            local swallowed = swallowedKeys[keyCode] or false
            swallowedKeys[keyCode] = nil
            return swallowed
        end
        if not active then
            return false
        end

        swallowedKeys[keyCode] = true
        local flags = keyEvent:getFlags()
        if keyCode == hs.keycodes.map.escape or flags.cmd or flags.ctrl or flags.alt then
            active = false
            buffer = ""
        else
            local characters = keyEvent:getCharacters()
            if not characters or characters == "" or characters:find("%c") then
                active = false
                buffer = ""
            else
                buffer = buffer .. characters
                local output = sequences[buffer]
                if output ~= nil then
                    active = false
                    buffer = ""
                    hs.eventtap.keyStrokes(output)
                elseif not prefixes[buffer] then
                    active = false
                    buffer = ""
                end
            end
        end
        return true
    end)
    tap:start()
    return compose
end

return compose
