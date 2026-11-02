local musicBlocker = {}
local watcher
local menuItem
local enabled = true

local bundleIDs = {
    ["com.apple.Music"] = true,
    ["com.apple.iTunes"] = true,
}

local function stopMusicApps()
    for bundleID in pairs(bundleIDs) do
        for _, app in ipairs(hs.application.applicationsForBundleID(bundleID) or {}) do
            app:kill9()
        end
    end
end

local function updateMenuItem()
    menuItem:setTitle(enabled and "♫" or "♪")
    menuItem:setTooltip(enabled and "Music and iTunes blocked" or "Music and iTunes allowed")
end

local function setEnabled(value)
    enabled = value
    updateMenuItem()
    if enabled then
        stopMusicApps()
    end
end

function musicBlocker.start()
    if watcher then
        watcher:stop()
    end
    if menuItem then
        menuItem:delete()
    end

    watcher = hs.application.watcher.new(function(_, event, app)
        if enabled and event == hs.application.watcher.launching and app
            and bundleIDs[app:bundleID()] then
            app:kill9()
        end
    end):start()

    menuItem = assert(hs.menubar.new(), "Could not create music blocker menu item")
    menuItem:setClickCallback(function()
        setEnabled(not enabled)
    end)
    updateMenuItem()

    if enabled then
        stopMusicApps()
    end
end

return musicBlocker
