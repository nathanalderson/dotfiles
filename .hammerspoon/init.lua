local dragScroll = require("drag_scroll")
local workspaceSwitch = require("workspace_switch")

workspaceSwitch.start({ velocity = 65 })

dragScroll.start({
	sensitivity = 1.5,
	acceleration = 0.4,
	referenceSpeed = 500,
	maxMultiplier = 4,
	threshold = 4,
	horizontal = true,
	invert = true,
})
