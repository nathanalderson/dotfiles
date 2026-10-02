local dragScroll = require("drag_scroll")

dragScroll.start({
	sensitivity = 1.5,
	acceleration = 0.4,
	referenceSpeed = 500,
	maxMultiplier = 4,
	threshold = 4,
	horizontal = true,
	invert = true,
})
