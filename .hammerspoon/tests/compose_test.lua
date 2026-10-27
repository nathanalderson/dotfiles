local callback
local outputs = {}
local taps = {}
local types = { keyDown = 10, keyUp = 11 }
local codes = { f20 = 90, escape = 53 }

local mockHs = {
    keycodes = { map = codes },
    eventtap = {
        event = { types = types },
        new = function(events, handler)
            assert(events[1] == types.keyDown and events[2] == types.keyUp)
            callback = handler
            local tap = {
                start = function(self) self.running = true end,
                stop = function(self) self.running = false end,
            }
            taps[#taps + 1] = tap
            return tap
        end,
        keyStrokes = function(text) outputs[#outputs + 1] = text end,
    },
}

local environment = setmetatable({ hs = mockHs }, { __index = _G })
local chunk
if setfenv then
    chunk = setfenv(assert(loadfile(".hammerspoon/compose.lua")), environment)
else
    chunk = assert(loadfile(".hammerspoon/compose.lua", "t", environment))
end
local compose = chunk()
local sequences = dofile(".hammerspoon/compose_sequences.lua")

local function send(kind, code, characters, flags)
    return callback({
        getType = function() return kind end,
        getKeyCode = function() return code end,
        getFlags = function() return flags or {} end,
        getCharacters = function() return characters end,
    })
end

local function begin()
    assert(send(types.keyDown, codes.f20))
end

local function finish()
    assert(send(types.keyUp, codes.f20))
end

local function tapCompose()
    begin()
    finish()
end

local function typeSequence(sequence)
    local count = #outputs
    for index = 1, #sequence do
        local character = sequence:sub(index, index)
        assert(send(types.keyDown, 1, character))
        assert(send(types.keyUp, 1, character))
        if index < #sequence then
            assert(#outputs == count, "Must not complete a partial sequence")
        end
    end
end

compose.start(sequences)
assert(taps[1].running)
assert(not send(types.keyDown, 1, "x"))
assert(not send(types.keyUp, 1, "x"))

local sequenceCount = 0
for sequence, output in pairs(sequences) do
    local count = #outputs
    tapCompose()
    typeSequence(sequence)
    assert(#outputs == count + 1 and outputs[#outputs] == output, sequence)
    assert(not send(types.keyDown, 1, "x"), "Typing after completion must pass through")
    assert(not send(types.keyUp, 1, "x"))
    sequenceCount = sequenceCount + 1
end
assert(sequences.shrug == "¯\\_(ツ)_/¯")
assert(sequences["--."] == "–" and sequences["---"] == "—")
assert(sequences["--"] == nil and sequences["<->"] == nil and sequences["<=>"] == nil)
assert(sequences.upsilon == nil and sequences[".upsilon"] == "υ")
local greekLetters = {
    { "alpha", "α", "Α" },
    { "beta", "β", "Β" },
    { "gamma", "γ", "Γ" },
    { "delta", "δ", "Δ" },
    { "epsilon", "ε", "Ε" },
    { "zeta", "ζ", "Ζ" },
    { "eta", "η", "Η" },
    { "theta", "θ", "Θ" },
    { "iota", "ι", "Ι" },
    { "kappa", "κ", "Κ" },
    { "lambda", "λ", "Λ" },
    { "mu", "μ", "Μ" },
    { "nu", "ν", "Ν" },
    { "xi", "ξ", "Ξ" },
    { "omicron", "ο", "Ο" },
    { "pi", "π", "Π" },
    { "rho", "ρ", "Ρ" },
    { "sigma", "σ", "Σ" },
    { "tau", "τ", "Τ" },
    { "upsilon", "υ", "Υ" },
    { "phi", "φ", "Φ" },
    { "chi", "χ", "Χ" },
    { "psi", "ψ", "Ψ" },
    { "omega", "ω", "Ω" },
}
for _, letter in ipairs(greekLetters) do
    local name, lower, upper = letter[1], letter[2], letter[3]
    local capitalized = name:sub(1, 1):upper() .. name:sub(2)
    assert(sequences[name == "upsilon" and ".upsilon" or name] == lower, name)
    assert(sequences[capitalized] == upper, capitalized)
end
assert(sequences.finalsigma == "ς")

local overlappingCount = #outputs
tapCompose()
assert(send(types.keyDown, 14, "e"))
assert(#outputs == overlappingCount)
assert(send(types.keyDown, 39, "'"))
assert(#outputs == overlappingCount + 1 and outputs[#outputs] == sequences["e'"])
assert(send(types.keyUp, 14, "e"))
assert(send(types.keyUp, 39, "'"))
assert(not send(types.keyUp, 39, "'"))

local count = #outputs
tapCompose()
finish()
finish()
assert(#outputs == count, "Compose release must not insert anything")
typeSequence("--")
assert(#outputs == count, "An incomplete sequence must remain pending")
typeSequence(".")
assert(outputs[#outputs] == sequences["--."])

count = #outputs
tapCompose()
typeSequence("?")
assert(send(types.keyDown, 1, "q"))
assert(send(types.keyUp, 1, "q"))
assert(#outputs == count, "Impossible sequences must cancel silently")
assert(not send(types.keyDown, 1, "x"))
assert(not send(types.keyUp, 1, "x"))

tapCompose()
typeSequence("--")
assert(send(types.keyDown, codes.escape, "\27"))
assert(send(types.keyUp, codes.escape))
assert(#outputs == count, "Escape must cancel without insertion")
assert(not send(types.keyDown, 1, "-"), "Typing after Escape must pass through")
assert(not send(types.keyUp, 1, "-"))

tapCompose()
assert(send(types.keyDown, 1, "N", { shift = true }))
assert(send(types.keyUp, 1, "N"))
assert(send(types.keyDown, 2, "~", { shift = true }))
assert(send(types.keyUp, 2, "~"))
assert(outputs[#outputs] == sequences["N~"])

count = #outputs
begin()
typeSequence("--")
begin()
typeSequence("-")
assert(outputs[#outputs] == sequences["---"], "Compose repeats must not reset the buffer")
assert(#outputs == count + 1)
begin()
assert(not send(types.keyDown, 1, "x"), "Repeats after completion must not rearm compose")
assert(not send(types.keyUp, 1, "x"))
finish()
assert(#outputs == count + 1, "Release after completion must not insert twice")

tapCompose()
typeSequence("--")
tapCompose()
typeSequence("e'")
assert(outputs[#outputs] == sequences["e'"], "A fresh tap must restart a partial sequence")

for _, flags in ipairs({ { cmd = true }, { ctrl = true }, { alt = true } }) do
    count = #outputs
    tapCompose()
    assert(send(types.keyDown, 1, "-", flags))
    assert(send(types.keyUp, 1))
    assert(#outputs == count, "Shortcut modifiers must cancel composition")
    assert(not send(types.keyDown, 1, "x"))
    assert(not send(types.keyUp, 1, "x"))
end

for _, character in ipairs({ "", "\8" }) do
    count = #outputs
    tapCompose()
    assert(send(types.keyDown, 1, character))
    assert(send(types.keyUp, 1))
    assert(#outputs == count, "Non-text input must cancel composition")
    assert(not send(types.keyDown, 1, "x"))
    assert(not send(types.keyUp, 1, "x"))
end

tapCompose()
assert(send(types.keyDown, 1))
assert(send(types.keyUp, 1))
assert(not send(types.keyDown, 1, "x"), "Missing characters must cancel composition")
assert(not send(types.keyUp, 1, "x"))

tapCompose()
typeSequence("--")
compose.start(sequences)
assert(not taps[1].running and taps[2].running)
count = #outputs
finish()
assert(#outputs == count, "Restart must clear pending composition")
assert(not send(types.keyDown, 1, "x"))

assert(not pcall(compose.start, "invalid"))
assert(not pcall(compose.start, { [""] = "x" }))
assert(not pcall(compose.start, { [1] = "x" }))
assert(not pcall(compose.start, { x = false }))
assert(not pcall(compose.start, { a = "x", ab = "y" }), "Prefix conflicts must be rejected")
compose.stop()
assert(not taps[2].running)
print("Compose tests passed (" .. sequenceCount .. " mappings)")
