FlexibleBars = FlexibleBars or {}
local FB = FlexibleBars

FB.name = "FlexibleBars"
FB.varversion = 1
FB.DefaultSettings = {}

FB.TEMPLATE_BASE_WIDTH = 250
FB.TEMPLATE_BASE_HEIGHT = 25

local math_floor = math.floor
local string_format = string.format
local tostring = tostring
local unpack = unpack
local GetUnitPower = GetUnitPower
local GetUnitAttributeVisualizerEffectInfo = GetUnitAttributeVisualizerEffectInfo
local zo_rad = zo_rad

local ANCHOR_POINTS = {
	L = { T = TOPLEFT,  M = LEFT,   B = BOTTOMLEFT  },
	C = { T = TOP,      M = CENTER, B = BOTTOM       },
	R = { T = TOPRIGHT, M = RIGHT,  B = BOTTOMRIGHT  },
}

FB.POSITION_NAMES = {
	left   = { "X", "L" },
	center = { "X", "C" },
	right  = { "X", "R" },
	top    = { "Y", "T" },
	mid    = { "Y", "M" },
	bottom = { "Y", "B" },
}

FB.BAR_DEFS             = {}
FB.powerControlLookup   = {}
local powerControlBasegame = {}

FB.powerCache = {}

local function FormatNumber(num)
	num = math_floor(num or 0)
	if num >= 1000 then
		local k = num / 1000
		if k == math_floor(k) then
			return string_format("%dk", math_floor(k))
		else
			return string_format("%.1fk", k)
		end
	end
	return tostring(num)
end

local function GetPercentColor(current, max)
	local pct = (max > 0) and (current / max) or 0
	if pct > 0.50 then
		return "|c00FF00"
	elseif pct >= 0.25 then
		return "|cFF9900"
	else
		return "|cFF0000"
	end
end

function FB.GetPositions(powerVars)
	local offsets = {}
	local positionData = {}
	local anchorData = {}
	for name, data in pairs(FB.POSITION_NAMES) do
		if type(powerVars.pos[name]) == "number" then
			positionData[data[1]] = data[2]
			offsets[data[1]] = powerVars.pos[name]
			anchorData[data[1]] = name
		end
	end

	local safeX = positionData.X or "C"
	local safeY = positionData.Y or "M"
	local anchorPoint = ANCHOR_POINTS[safeX][safeY]

	return offsets, anchorData, anchorPoint
end

function FB.PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, value, max)
	local powerControl = FB.powerControlLookup[powerType]
	if powerControl then
		local def = FB.BAR_DEFS[powerType]
		local isHealth = def and def.varKey == "health"

		local shieldValue = 0
		if isHealth then
			shieldValue = GetUnitAttributeVisualizerEffectInfo(
				"player",
				ATTRIBUTE_VISUAL_POWER_SHIELDING,
				STAT_MITIGATION,
				ATTRIBUTE_HEALTH,
				POWERTYPE_HEALTH
			) or 0
		end

		local cache = FB.powerCache[powerType]
		if not cache then return end
		if cache.value == value and cache.max == max and cache.shield == shieldValue then
			return
		end

		cache.value = value
		cache.max   = max
		cache.shield = shieldValue

		local resourceBar = powerControl.resourceBar
		if resourceBar then
			resourceBar:SetMinMax(0, max)
			ZO_StatusBar_SmoothTransition(resourceBar, value, max)
		end

		local colorCode   = GetPercentColor(value, max)
		local pctText     = (max > 0) and math_floor((value / max) * 100) or 0
		local valueString
		local percentString

		if isHealth then
			if shieldValue > 0 then
				valueString = string_format("|cFFFFFF%s  |c00CCFF%s|r", FormatNumber(value), FormatNumber(shieldValue))
			else
				valueString = string_format("|cFFFFFF%s|r", FormatNumber(value))
			end
		else
			valueString = string_format("|cFFFFFF%s|r", FormatNumber(value))
		end

		percentString = string_format("%s%d%%|r", colorCode, pctText)

		if powerControl.valueLabel   then powerControl.valueLabel:SetText(valueString)   end
		if powerControl.percentLabel then powerControl.percentLabel:SetText(percentString) end
	end
end

function FB.SetBarVisibility(combatFlag, hidden)
	local control         = FB.powerControlLookup[combatFlag]
	local baseGameControl = powerControlBasegame[combatFlag]
	if not control or not baseGameControl then return end
	
	control:SetHidden(hidden)
	
	if not hidden then
		baseGameControl:SetHidden(true)
		baseGameControl:SetAlpha(0)
		
		if not baseGameControl.fbHooked then
			ZO_PreHook(baseGameControl, "SetAlpha", function(self, alpha)
				local def = FB.BAR_DEFS[combatFlag]
				local powerVars = FB.vars[def.varKey]
				if alpha > 0 and (not powerVars.hide) then
					return true 
				end
			end)
			baseGameControl.fbHooked = true
		end
	else
		baseGameControl:SetHidden(false)
		baseGameControl:SetAlpha(1)
	end
end

function FB.OnAddOnLoaded(event, addonName)
	if addonName ~= FB.name then return end
	FB:Initialize()
end

function FB:Initialize()
	FB.vars = ZO_SavedVars:NewAccountWide("FlexibleBarsVars", FB.varversion, nil, FB.DefaultSettings)

	local defaultPreset = FB.presets["Base Game"]
	local barKeys = {"health", "stam", "mag"}
	
	for _, key in ipairs(barKeys) do
		if FB.vars[key] == nil then
			local copied = FB.CopyPreset({ [key] = defaultPreset[key] })
			FB.vars[key] = copied[key]
		end
	end

	FB.BAR_DEFS[COMBAT_MECHANIC_FLAGS_MAGICKA] = {
		varKey         = "mag",
		name           = "|c0252c7Magicka|r",
		decolouredName = "Magicka",
	}
	FB.BAR_DEFS[COMBAT_MECHANIC_FLAGS_STAMINA] = {
		varKey         = "stam",
		name           = "|c039900Stamina|r",
		decolouredName = "Stamina",
	}
	FB.BAR_DEFS[COMBAT_MECHANIC_FLAGS_HEALTH] = {
		varKey         = "health",
		name           = "|c991313Health|r",
		decolouredName = "Health",
	}

	FB.powerCache[COMBAT_MECHANIC_FLAGS_MAGICKA] = { value = -1, max = -1, shield = -1 }
	FB.powerCache[COMBAT_MECHANIC_FLAGS_STAMINA] = { value = -1, max = -1, shield = -1 }
	FB.powerCache[COMBAT_MECHANIC_FLAGS_HEALTH]  = { value = -1, max = -1, shield = -1 }

	FB.powerControlLookup[COMBAT_MECHANIC_FLAGS_MAGICKA]  = FlexibleBarsMag
	FB.powerControlLookup[COMBAT_MECHANIC_FLAGS_HEALTH]   = FlexibleBarsHealth
	FB.powerControlLookup[COMBAT_MECHANIC_FLAGS_STAMINA]  = FlexibleBarsStam

	powerControlBasegame[COMBAT_MECHANIC_FLAGS_MAGICKA] = ZO_PlayerAttributeMagicka
	powerControlBasegame[COMBAT_MECHANIC_FLAGS_HEALTH]  = ZO_PlayerAttributeHealth
	powerControlBasegame[COMBAT_MECHANIC_FLAGS_STAMINA] = ZO_PlayerAttributeStamina

	local flexibleBarsFragment = ZO_HUDFadeSceneFragment:New(FlexibleBarsToplevel, DEFAULT_SCENE_TRANSITION_TIME, 0)
	HUD_SCENE:AddFragment(flexibleBarsFragment)
	HUD_UI_SCENE:AddFragment(flexibleBarsFragment)

	FB.recentPowerUpdate = ZO_MostRecentPowerUpdateHandler:New("FlexibleBarsPowerUpdate", FB.PowerUpdateHandlerFunction)
	FB.recentPowerUpdate:AddFilterForEvent(REGISTER_FILTER_UNIT_TAG, "player")

	for combatFlag, def in pairs(FB.BAR_DEFS) do
		local v         = FB.powerControlLookup[combatFlag]
		local powerVars = FB.vars[def.varKey]

		v.resourceBar  = v:GetNamedChild("Resource")
		v.valueLabel   = v:GetNamedChild("Value")
		v.percentLabel = v:GetNamedChild("Percent")

		local value, max = GetUnitPower("player", combatFlag)
		FB.PowerUpdateHandlerFunction("player", nil, combatFlag, value, max)

		v:SetScale(powerVars.scale or 1)

		v.resourceBar:SetColor(unpack(powerVars.colour))
		local scaleX = powerVars.desiredX / FB.TEMPLATE_BASE_WIDTH
		local scaleY = powerVars.desiredY / FB.TEMPLATE_BASE_HEIGHT
		v.resourceBar:SetTransformScaleX(scaleX)
		v.resourceBar:SetTransformScaleY(scaleY)

		local textScale = powerVars.textScale or 1
		v.valueLabel:SetTransformScale(scaleY * textScale)
		v.valueLabel:SetTransformRotationZ(zo_rad(powerVars.textRotation or 0))
		v.valueLabel:SetHidden(powerVars.textHide)
		v.valueLabel:SetTransformOffsetX(powerVars.textOffsetX or 0)
		v.valueLabel:SetTransformOffsetY(powerVars.textOffsetY or 0)

		v.percentLabel:SetTransformScale(scaleY * (powerVars.percentScale or 1))
		v.percentLabel:SetTransformRotationZ(zo_rad(powerVars.percentRotation or 0))
		v.percentLabel:SetTransformOffsetX(powerVars.percentOffsetX or 0)
		v.percentLabel:SetTransformOffsetY(powerVars.percentOffsetY or 0)
		v.percentLabel:SetHidden(powerVars.textHide)

		v:SetTransformRotationZ(zo_rad(powerVars.rotation))
		FB.SetBarVisibility(combatFlag, powerVars.hide)

		local offsets, _, anchorPoint = FB.GetPositions(powerVars)
		v:ClearAnchors()
		v:SetAnchor(anchorPoint, GuiRoot, anchorPoint, offsets.X or 0, offsets.Y or 0)
	end

	-- AYAR MENÜSÜ BURADA ÇAĞRILIYOR
	if FB.BuildSettingsPanel then
		FB.BuildSettingsPanel()
	end

	local grad       = ZO_ColorDef:New(unpack(FB.vars.health.colour))
	local shieldGrad = ZO_ColorDef:New(0.0, 0.8, 1, 1)

	local VISUALIZER_POWER_SHIELD_LAYOUT_DATA = {
		barLeftOverlayTemplate        = "FlexibleBars_ShieldBarTemplate",
		fakeHealthGradientOverride    = {grad, grad},
		powerShieldGradientOverride   = {shieldGrad, shieldGrad},
	}

	local healthControl = FB.powerControlLookup[COMBAT_MECHANIC_FLAGS_HEALTH]
	local healthResourceBar = healthControl:GetNamedChild("Resource")
	
	healthResourceBar.barControls = {healthResourceBar}
	FB.visualizer = ZO_UnitAttributeVisualizer:New("player", nil, healthResourceBar)
	FB.shieldVis  = ZO_UnitVisualizer_PowerShieldModule:New(VISUALIZER_POWER_SHIELD_LAYOUT_DATA)
	FB.visualizer:AddModule(FB.shieldVis)
	FB.shieldVis:InitializeBarValues()

	local healthFlag
	for flag, def in pairs(FB.BAR_DEFS) do
		if def.varKey == "health" then healthFlag = flag break end
	end

	SecurePostHook(FB.shieldVis, "OnValueChanged", function()
		local current, max = GetUnitPower("player", healthFlag)
		FB.PowerUpdateHandlerFunction("player", nil, healthFlag, current, max)
	end)

	EVENT_MANAGER:UnregisterForEvent(FB.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(FB.name, EVENT_ADD_ON_LOADED, FB.OnAddOnLoaded)