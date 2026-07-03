FlexibleBars = FlexibleBars or {}
local FB = FlexibleBars

local tostring = tostring
local unpack = unpack
local zo_rad = zo_rad

function FB.BuildSettingsPanel()
	local panelName = "FlexibleBarsSettingsPanel"
	local panelData = {
		type   = "panel",
		name   = "|cFFD700Flexible Bars|r",
		author = "|c0DC1CF@Zerakthion|r",
		registerForRefresh = true,
	}

	-- Ana Ekran (Sadece Genel Ayarlar ve Alt Menüleri Barındırır)
	local optionsTable = {
		{
			type  = "description",
			title = "|cFFD700Flexible Bars|r",
			text  = "A tool to move attribute bars with great flexibility!",
			width = "full",
		},
		{
			type = "header",
			name = "Presets & General",
		},
		{
			type     = "dropdown",
			name     = "Select Preset",
			choices  = FB.GetPresetNames(),
			getFunc  = function() return FB.selectedPreset or "Base Game" end,
			setFunc  = function(var) FB.selectedPreset = var end,
			width    = "half",
		},
		{
			type    = "button",
			name    = "[Load Selected Preset]",
			tooltip = "Loads the selected preset.\n\n|cFF0000Your current settings will be overwritten and the UI will reload immediately.|r",
			width   = "half",
			func    = function()
				local presetName = FB.selectedPreset or "Base Game"
				if FB.presets[presetName] and FB.vars then
					ZO_Dialogs_ShowDialog("FlexibleBarsConfirmDialogue", {
						yesCallback = function()
							local copied = FB.CopyPreset(FB.presets[presetName])
							for k, v in pairs(copied) do
								FB.vars[k] = v
							end
							ReloadUI()
						end
					}, {
						titleParams   = { "Loading Preset" },
						mainTextParams = { "Are you sure you would like to load the preset \"" .. tostring(presetName) .. "\"?" },
						warningParams  = { "Accepting will immediately start a reload UI, and will overwrite any saved settings." },
					})
				end
			end,
		},
		{
			type    = "button",
			name    = "|cFF5555[Reload UI]|r",
			tooltip = "Click here to reload your UI! (Will result in a load screen)",
			width   = "full",
			func    = function() ReloadUI() end,
		},
	}

	-- Her Bar İçin Ayrı Bir Alt Menü (Submenu) Oluşturuyoruz
	for combatFlag, def in pairs(FB.BAR_DEFS) do
		local v              = FB.powerControlLookup[combatFlag]
		local powerVars      = FB.vars[def.varKey]
		local resourceName         = def.decolouredName
		local resourceColouredName = def.name

		local healthWarning = ""
		if def.varKey == "health" then
			healthWarning = "\n\n|cFF0000After adjusting the health colour, please reload your UI to fully apply the change to your shields.|r"
		end

		-- Alt Menü İçeriği (Gruplandırılmış Halde)
		local subControls = {
			{
				type = "header",
				name = "Visibility & Position",
			},
			{
				type    = "checkbox",
				name    = "Show " .. resourceName .. " Bar",
				tooltip = "Enabling this will hide the base game " .. resourceColouredName .. " resource bar.",
				width   = "full",
				getFunc = function() return not powerVars.hide end,
				setFunc = function(value)
					powerVars.hide = not value
					FB.SetBarVisibility(combatFlag, powerVars.hide)
				end,
			},
			{
				type    = "slider",
				name    = "X Position (Horizontal)",
				tooltip = "Adjusts the horizontal position of the bar.",
				min = -3000, max = 3000, step = 1,
				getFunc = function()
					for key, val in pairs(powerVars.pos) do
						if FB.POSITION_NAMES[key] and FB.POSITION_NAMES[key][1] == "X" then return val end
					end
					return 0
				end,
				setFunc = function(val)
					for key, _ in pairs(powerVars.pos) do
						if FB.POSITION_NAMES[key] and FB.POSITION_NAMES[key][1] == "X" then
							powerVars.pos[key] = val
							local newOffsets, _, newAnchorPoint = FB.GetPositions(powerVars)
							v:ClearAnchors()
							v:SetAnchor(newAnchorPoint, GuiRoot, newAnchorPoint, newOffsets.X or 0, newOffsets.Y or 0)
							break
						end
					end
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Y Position (Vertical)",
				tooltip = "Adjusts the vertical position of the bar.",
				min = -3000, max = 3000, step = 1,
				getFunc = function()
					for key, val in pairs(powerVars.pos) do
						if FB.POSITION_NAMES[key] and FB.POSITION_NAMES[key][1] == "Y" then return val end
					end
					return 0
				end,
				setFunc = function(val)
					for key, _ in pairs(powerVars.pos) do
						if FB.POSITION_NAMES[key] and FB.POSITION_NAMES[key][1] == "Y" then
							powerVars.pos[key] = val
							local newOffsets, _, newAnchorPoint = FB.GetPositions(powerVars)
							v:ClearAnchors()
							v:SetAnchor(newAnchorPoint, GuiRoot, newAnchorPoint, newOffsets.X or 0, newOffsets.Y or 0)
							break
						end
					end
				end,
				width = "half",
			},
			{
				type = "header",
				name = "Appearance & Size",
			},
			{
				type    = "slider",
				name    = "Global Scale %",
				tooltip = "Increases or decreases the overall size of the bar and its text.",
				min = 25, max = 200, step = 5,
				getFunc = function() return (powerVars.scale or 1) * 100 end,
				setFunc = function(val)
					powerVars.scale = val / 100
					v:SetScale(powerVars.scale)
				end,
				width = "full",
			},
			{
				type    = "slider",
				name    = "Rotation (Degrees)",
				tooltip = "This sets the rotation of the " .. resourceColouredName .. " bar, in degrees.",
				min = 0, max = 360, step = 1,
				getFunc = function() return powerVars.rotation or 0 end,
				setFunc = function(theta)
					powerVars.rotation = theta
					v:SetTransformRotationZ(zo_rad(theta))
				end,
				width = "full",
			},
			{
				type    = "slider",
				name    = "Width",
				tooltip = "This sets the width of the " .. resourceColouredName .. " bar.",
				min = 1, max = GuiRoot:GetWidth(), step = 1,
				getFunc = function() return powerVars.desiredX end,
				setFunc = function(x)
					powerVars.desiredX = x
					v.resourceBar:SetTransformScaleX(x / FB.TEMPLATE_BASE_WIDTH)
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Height",
				tooltip = "This sets the height of the " .. resourceColouredName .. " bar.",
				min = 1, max = GuiRoot:GetHeight(), step = 1,
				getFunc = function() return powerVars.desiredY end,
				setFunc = function(y)
					powerVars.desiredY = y
					v.resourceBar:SetTransformScaleY(y / FB.TEMPLATE_BASE_HEIGHT)
					v.valueLabel:SetTransformScale(y / FB.TEMPLATE_BASE_HEIGHT * (powerVars.textScale or 1))
					v.percentLabel:SetTransformScale(y / FB.TEMPLATE_BASE_HEIGHT * (powerVars.percentScale or 1))
				end,
				width = "half",
			},
			{
				type    = "colorpicker",
				name    = "Bar Colour",
				tooltip = "This sets the colour of the " .. resourceColouredName .. " bar!" .. healthWarning,
				getFunc = function() return unpack(powerVars.colour) end,
				setFunc = function(r, g, b)
					powerVars.colour = {r, g, b}
					v.resourceBar:SetColor(r, g, b)
					if def.varKey == "health" and FB.shieldVis then
						local grad = ZO_ColorDef:New(r, g, b)
						FB.shieldVis.fakeHealthGradientOverride = {grad, grad}
						FB.shieldVis:InitializeBarValues()
					end
				end,
				width = "full",
			},
			{
				type = "header",
				name = "Value Text Options",
			},
			{
				type    = "checkbox",
				name    = "Show All Text",
				tooltip = "Hides or shows the numbers on the bar.",
				width   = "full",
				getFunc = function() return not powerVars.textHide end,
				setFunc = function(value)
					powerVars.textHide = not value
					v.valueLabel:SetHidden(powerVars.textHide)
					v.percentLabel:SetHidden(powerVars.textHide)
				end,
			},
			{
				type    = "slider",
				name    = "Value Text Scale %",
				tooltip = "This sets the scale of the " .. resourceColouredName .. " text (in percent).",
				min = 10, max = 1000, step = 10,
				getFunc = function() return (powerVars.textScale or 1) * 100 end,
				setFunc = function(scale)
					powerVars.textScale = scale / 100
					v.valueLabel:SetTransformScale(powerVars.desiredY / FB.TEMPLATE_BASE_HEIGHT * scale / 100)
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Value Text Rotation",
				tooltip = "This sets the rotation of the " .. resourceColouredName .. " text (in degrees).",
				min = 0, max = 360, step = 1,
				getFunc = function() return powerVars.textRotation or 0 end,
				setFunc = function(theta)
					powerVars.textRotation = theta
					v.valueLabel:SetTransformRotationZ(zo_rad(theta))
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Value Text X Offset",
				min = -GuiRoot:GetWidth(), max = GuiRoot:GetWidth(), step = 1,
				getFunc = function() return powerVars.textOffsetX or 0 end,
				setFunc = function(x)
					powerVars.textOffsetX = x
					v.valueLabel:SetTransformOffsetX(x)
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Value Text Y Offset",
				min = -GuiRoot:GetHeight(), max = GuiRoot:GetHeight(), step = 1,
				getFunc = function() return powerVars.textOffsetY or 0 end,
				setFunc = function(y)
					powerVars.textOffsetY = y
					v.valueLabel:SetTransformOffsetY(y)
				end,
				width = "half",
			},
			{
				type = "header",
				name = "Percentage Text Options",
			},
			{
				type    = "slider",
				name    = "Percent Text Scale %",
				tooltip = "Adjusts the scale of the percentage text (in percent).",
				min = 10, max = 1000, step = 10,
				getFunc = function() return (powerVars.percentScale or 1) * 100 end,
				setFunc = function(scale)
					powerVars.percentScale = scale / 100
					v.percentLabel:SetTransformScale(powerVars.desiredY / FB.TEMPLATE_BASE_HEIGHT * (powerVars.percentScale or 1))
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Percent Text Rotation",
				tooltip = "Adjusts the rotation of the percentage text (in degrees).",
				min = 0, max = 360, step = 1,
				getFunc = function() return powerVars.percentRotation or 0 end,
				setFunc = function(theta)
					powerVars.percentRotation = theta
					v.percentLabel:SetTransformRotationZ(zo_rad(theta))
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Percent Text X Offset",
				tooltip = "Adjusts the horizontal position of the percentage text.",
				min = -GuiRoot:GetWidth(), max = GuiRoot:GetWidth(), step = 1,
				getFunc = function() return powerVars.percentOffsetX or 0 end,
				setFunc = function(x)
					powerVars.percentOffsetX = x
					v.percentLabel:SetTransformOffsetX(x)
				end,
				width = "half",
			},
			{
				type    = "slider",
				name    = "Percent Text Y Offset",
				tooltip = "Adjusts the vertical position of the percentage text.",
				min = -GuiRoot:GetHeight(), max = GuiRoot:GetHeight(), step = 1,
				getFunc = function() return powerVars.percentOffsetY or 0 end,
				setFunc = function(y)
					powerVars.percentOffsetY = y
					v.percentLabel:SetTransformOffsetY(y)
				end,
				width = "half",
			},
		}

		-- Alt menüyü ana options tablosuna "submenu" olarak ekliyoruz
		optionsTable[#optionsTable + 1] = {
			type = "submenu",
			name = resourceColouredName .. " Settings",
			controls = subControls,
		}
	end

	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)
end