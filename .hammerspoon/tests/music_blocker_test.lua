local callback
local clickCallback
local stopped = {}
local killed = {}
local menu = {
    setTitle = function(self, title) self.title = title end,
    setTooltip = function(self, tooltip) self.tooltip = tooltip end,
    setClickCallback = function(_, fn) clickCallback = fn end,
    delete = function(self) self.deleted = true end,
}
local currentApps = {}
local watcher = {
    start = function(self) self.running = true; return self end,
    stop = function(self) self.running = false; stopped[#stopped + 1] = self end,
}
local mockHs = {
    application = {
        watcher = {
            launching = 0,
            new = function(fn)
                callback = fn
                watcher = {
                    start = function(self) self.running = true; return self end,
                    stop = function(self) self.running = false; stopped[#stopped + 1] = self end,
                }
                return watcher
            end,
        },
        applicationsForBundleID = function(bundleID)
            return currentApps[bundleID] or {}
        end,
    },
    menubar = {
        new = function()
            local item = {
                setTitle = function(self, title) self.title = title end,
                setTooltip = function(self, tooltip) self.tooltip = tooltip end,
                setClickCallback = function(_, fn) clickCallback = fn end,
                delete = function(self) self.deleted = true end,
            }
            menu = item
            return item
        end,
    },
}

local environment = setmetatable({ hs = mockHs }, { __index = _G })
local chunk
if setfenv then
    chunk = setfenv(assert(loadfile(".hammerspoon/music_blocker.lua")), environment)
else
    chunk = assert(loadfile(".hammerspoon/music_blocker.lua", "t", environment))
end
local musicBlocker = chunk()

local function app(bundleID)
    return {
        bundleID = function() return bundleID end,
        kill9 = function() killed[#killed + 1] = bundleID end,
    }
end

local existingMusic = app("com.apple.Music")
currentApps["com.apple.Music"] = { existingMusic }
musicBlocker.start()
assert(watcher.running)
assert(menu.title == "♫" and menu.tooltip == "Music and iTunes blocked")
assert(killed[1] == "com.apple.Music", "Starting enabled must stop already-running Music")

local music = app("com.apple.Music")
callback("Music", mockHs.application.watcher.launching, music)
assert(killed[#killed] == "com.apple.Music", "Music must be stopped before launch")

local itunes = app("com.apple.iTunes")
callback("iTunes", mockHs.application.watcher.launching, itunes)
assert(killed[#killed] == "com.apple.iTunes", "iTunes must be stopped before launch")

local count = #killed
callback("Other", mockHs.application.watcher.launching, app("com.example.Other"))
callback("Music", 1, music)
assert(#killed == count, "Other apps and non-launching events must pass through")

clickCallback()
assert(menu.title == "♪" and menu.tooltip == "Music and iTunes allowed")
count = #killed
callback("Music", mockHs.application.watcher.launching, music)
assert(#killed == count, "Disabled blocker must allow launches")

clickCallback()
assert(menu.title == "♫" and menu.tooltip == "Music and iTunes blocked")
assert(#killed > count, "Re-enabling must stop already-running Music")

local priorWatcher, priorMenu = watcher, menu
musicBlocker.start()
assert(not priorWatcher.running and priorMenu.deleted, "Restart must clean up prior watcher and menu")

print("Music blocker tests passed")
