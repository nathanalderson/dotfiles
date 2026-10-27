local compose = {}
local types = hs.eventtap.event.types
local tap
local active = false
local cancelled = false
local buffer = ""
local swallowedKeys = {}

function compose.stop()
    if tap then
        tap:stop()
        tap = nil
    end
    active = false
    cancelled = false
    buffer = ""
    swallowedKeys = {}
end

function compose.start(sequences)
    assert(type(sequences) == "table", "Compose sequences must be a table")
    for sequence, output in pairs(sequences) do
        assert(type(sequence) == "string" and sequence ~= "",
            "Compose sequences must be nonempty strings")
        assert(type(output) == "string", "Compose output must be a string for " .. sequence)
    end

    compose.stop()
    tap = hs.eventtap.new({ types.keyDown, types.keyUp }, function(keyEvent)
        local keyCode = keyEvent:getKeyCode()
        local isDown = keyEvent:getType() == types.keyDown
        if keyCode == hs.keycodes.map.f20 then
            if isDown then
                if not active then
                    active = true
                    cancelled = false
                    buffer = ""
                end
            elseif active then
                local output = not cancelled and sequences[buffer]
                active = false
                buffer = ""
                if output then
                    hs.eventtap.keyStrokes(output)
                end
            end
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
            cancelled = true
        elseif not cancelled then
            local characters = keyEvent:getCharacters()
            if not characters or characters == "" or characters:find("%c") then
                cancelled = true
            else
                buffer = buffer .. characters
            end
        end
        return true
    end)
    tap:start()
    return compose
end

return compose
