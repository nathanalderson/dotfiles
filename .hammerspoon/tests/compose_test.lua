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

local function typeSequence(sequence)
    for index = 1, #sequence do
        local character = sequence:sub(index, index)
        assert(send(types.keyDown, 1, character))
        assert(send(types.keyUp, 1, character))
    end
end

compose.start(sequences)
assert(taps[1].running)
assert(not send(types.keyDown, 1, "x"))
assert(not send(types.keyUp, 1, "x"))

local sequenceCount = 0
for sequence, output in pairs(sequences) do
    local count = #outputs
    begin()
    typeSequence(sequence)
    assert(#outputs == count, "Must wait for compose release")
    finish()
    assert(#outputs == count + 1 and outputs[#outputs] == output, sequence)
    sequenceCount = sequenceCount + 1
end
assert(sequences.shrug == "¯\\_(ツ)_/¯")
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
    assert(sequences[name] == lower, name)
    assert(sequences[capitalized] == upper, capitalized)
end
assert(sequences.finalsigma == "ς")

local overlappingCount = #outputs
begin()
assert(send(types.keyDown, 14, "e"))
assert(send(types.keyDown, 39, "'"))
assert(send(types.keyUp, 14, "e"))
assert(send(types.keyUp, 39, "'"))
assert(#outputs == overlappingCount, "Overlapping sequence keys must wait for compose release")
finish()
assert(#outputs == overlappingCount + 1 and outputs[#outputs] == sequences["e'"])

local count = #outputs
begin()
typeSequence("unknown")
finish()
begin()
finish()
finish()
assert(#outputs == count, "Unknown, empty and unmatched releases must be silent")

begin()
typeSequence("--")
assert(send(types.keyDown, codes.escape, "\27"))
assert(send(types.keyUp, codes.escape))
typeSequence("---")
finish()
assert(#outputs == count, "Escape must cancel until release")

begin()
assert(send(types.keyDown, 1, "N", { shift = true }))
assert(send(types.keyUp, 1, "N"))
assert(send(types.keyDown, 2, "~", { shift = true }))
assert(send(types.keyUp, 2, "~"))
finish()
assert(outputs[#outputs] == sequences["N~"])

begin()
typeSequence("--")
begin()
typeSequence("-")
finish()
assert(outputs[#outputs] == sequences["---"], "Compose repeats must not reset the buffer")

begin()
assert(send(types.keyDown, 1, "-"))
assert(send(types.keyUp, 1))
assert(send(types.keyDown, 1, "-"))
finish()
assert(outputs[#outputs] == sequences["--"])
assert(send(types.keyUp, 1), "Captured key-up must stay suppressed after compose release")
assert(not send(types.keyUp, 1))

for _, flags in ipairs({ { cmd = true }, { ctrl = true }, { alt = true } }) do
    count = #outputs
    begin()
    assert(send(types.keyDown, 1, "-", flags))
    assert(send(types.keyUp, 1))
    typeSequence("--")
    finish()
    assert(#outputs == count, "Shortcut modifiers must cancel composition")
end

for _, character in ipairs({ "", "\8" }) do
    count = #outputs
    begin()
    assert(send(types.keyDown, 1, character))
    assert(send(types.keyUp, 1))
    typeSequence("--")
    finish()
    assert(#outputs == count, "Non-text input must cancel composition")
end

begin()
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
compose.stop()
assert(not taps[2].running)
print("Compose tests passed (" .. sequenceCount .. " mappings)")
