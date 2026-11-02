require("hs.ipc")

local dragScroll = require("drag_scroll")
local workspaceSwitch = require("workspace_switch")
local windowLayout = require("window_layout")
local compose = require("compose")
local musicBlocker = require("music_blocker")

workspaceSwitch.start({ velocity = 2000 })
windowLayout.start()
compose.start(require("compose_sequences"))
musicBlocker.start()

dragScroll.start({
	sensitivity = 1.5,
	acceleration = 0.4,
	referenceSpeed = 500,
	maxMultiplier = 4,
	threshold = 4,
	horizontal = true,
	invert = true,
})
