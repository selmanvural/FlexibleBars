FlexibleBars = FlexibleBars or {}
local FB = FlexibleBars

FB.presets = {
	["Base Game"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = 0, bottom = -123 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = -400, bottom = -123 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = 400, bottom = -123 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	},
	["Vertical"] = {
		health = {
			colour = { 1, 0, 0.0156862754 },
			desiredX = 450,
			desiredY = 25,
			rotation = 90,
			pos = { mid = 0, center = -200 },
			hide = false,
			textHide = false,
			textScale = 1.4,
			textRotation = 270,
			textOffsetX = 30,
			textOffsetY = 200,
			percentScale = 1.6,
			percentRotation = 270,
			percentOffsetX = 0,
			percentOffsetY = -120,
		},
		mag = {
			colour = { 0.0039215689, 0.4117647111, 1 },
			desiredX = 215,
			desiredY = 25,
			rotation = 90,
			pos = { mid = -112.5, center = 200 },
			hide = false,
			textHide = false,
			textScale = 1.2,
			textRotation = 270,
			textOffsetX = -90,
			textOffsetY = 170,
			percentScale = 1.6,
			percentRotation = 270,
			percentOffsetX = -90,
			percentOffsetY = -225,
		},
		stam = {
			colour = { 0.0117, 0.6, 0 },
			desiredX = 215,
			desiredY = 25,
			rotation = 270,
			pos = { mid = 112.5, center = 200 },
			hide = false,
			textHide = false,
			textScale = 1.2,
			textRotation = 90,
			textOffsetX = -90,
			textOffsetY = -170,
			percentScale = 1.6,
			percentRotation = 90,
			percentOffsetX = -90,
			percentOffsetY = 225,
		},
	},
	["Stacked"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = -350, bottom = -173 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = -350, bottom = -148 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0},
			desiredX = 250,
			desiredY = 23,
			rotation = 0,
			pos = { center = -350, bottom = -123 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	},
	["Reticle"] = {
		health = {
			colour = {0.6, 0.0745, 0.0745},
			desiredX = 200,
			desiredY = 20,
			rotation = 0,
			pos = { center = 0, mid = 75 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		mag = {
			colour = {0.0078, 0.3216, 0.7804},
			desiredX = 200,
			desiredY = 20,
			rotation = 60,
			pos = { center = -64.9, mid = -37.5 },
			hide = false,
			textHide = false,
			textRotation = 0,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
		stam = {
			colour = {0.0117, 0.6, 0},
			desiredX = 200,
			desiredY = 20,
			rotation = 120,
			pos = { center = 64.9, mid = -37.5 },
			hide = false,
			textHide = false,
			textRotation = 180,
			textScale = 1.2,
			textOffsetX = 0,
			textOffsetY = 0,
		},
	}
}

function FB.CopyPreset(preset)
	local copy = {}
	for barName, barData in pairs(preset) do
		copy[barName] = {}
		for k, v in pairs(barData) do
			if type(v) == "table" then
				local inner = {}
				for ik, iv in pairs(v) do
					inner[ik] = iv
				end
				copy[barName][k] = inner
			else
				copy[barName][k] = v
			end
		end
	end
	return copy
end

function FB.GetPresetNames()
	local names = {}
	for name in pairs(FB.presets) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

ESO_Dialogs["FlexibleBarsConfirmDialogue"] = {
	canQueue = true,
	title = { text = "<<1>>" },
	mainText = { text = "<<1>>" },
	warning = { text = "<<1>>" },
	buttons = {
		{ text = "Yes", callback = function(dialogue) dialogue.data.yesCallback() end },
		{ text = "No" },
	},
}