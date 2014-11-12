-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = ns.cfg

local lib = CreateFrame("Frame")
local _, playerClass = UnitClass("player")

local shadows = {
	edgeFile = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\glowTex", 
	edgeSize = 4,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

-----------------------
-- Functions
-----------------------

-- Returns val1, val2 or val3 depending on frame
local retVal = function(f, val1, val2, val3)
	if f.mystyle == "player" or f.mystyle == "target" then
		return val1
	elseif f.mystyle == "raid" then
		return val3
	else
		return val2
	end
end

local updateTooltip = function(self)			
	GameTooltip:SetUnitAura(self:GetParent().__owner.unit, self:GetID(), self.filter)
		if self.owner and UnitExists(self.owner) then
			GameTooltip:AddLine(format("|cff1369ca* Cast by %s|r", UnitName(self.owner) or UNKNOWN))
		end
	GameTooltip:Show()
end

local formatTime = function(s)
	local day, hour, minute = 86400, 3600, 60
	if s >= day then
		return format("%dd", floor(s/day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s/hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s/minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100))/100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100))/100
end

local setTimer = function (self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = formatTime(self.timeLeft)
					self.time:SetText(time)
				if self.timeLeft < 5 then
					self.time:SetTextColor(1, 0.5, 0.5)
				else
					self.time:SetTextColor(.7, .7, .7)
				end
			else
				self.time:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

function framefix1px(f)
	f:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, 
		insets = {left = -1, right = -1, top = -1, bottom = -1} 
	})
	f:SetBackdropColor(.09,.09,.09,1)
	f:SetBackdropBorderColor(.2,.2,.2,1)
end

function frame1px1(f)
	f:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, 
		insets = {left = 1, right = 1, top = 1, bottom = 1} 
	})
	f:SetPoint("TOPLEFT", -2, 2)
	f:SetPoint("BOTTOMRIGHT", 2, -2)
	f:SetBackdropColor(.09,.09,.09,1)
	f:SetBackdropBorderColor(.2,.2,.2,1)
end

function frame1px1red(f)
	f:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, 
		insets = {left = 1, right = 1, top = 1, bottom = 1} 
	})
	f:SetPoint("TOPLEFT", -2, 2)
	f:SetPoint("BOTTOMRIGHT", 2, -2)

	f:SetBackdropColor(.09,.09,.09,1)
	f:SetBackdropBorderColor(.6,.1,.1,1)	
end

function CreateShadow(f)
	if f.shadow then return end
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -4, 4)
	shadow:SetPoint("BOTTOMRIGHT", 4, -4)
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, 1)
	f.shadow = shadow
	return shadow
end

-- Create Backdrop Function
lib.createBackdrop = function(f, size)
	f:SetBackdrop({
		bgFile =  [=[Interface\ChatFrame\ChatFrameBackground]=],
        edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, 
		insets = {left = 1, right = 1, top = 1, bottom = 1} 
	})
	f:SetPoint("TOPLEFT", -2, 2)
	f:SetPoint("BOTTOMRIGHT", 2, -2)
	f:SetBackdropColor(.09,.09,.09,1)
	f:SetBackdropBorderColor(.2,.2,.2,0)
	
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -3, 3)
	shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop(shadows)
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, 1)
	f.shadow = shadow
end

-- Right Click Menu
lib.spawnMenu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("^%l", string.upper)

	if(cunit == 'Vehicle') then
		cunit = 'Pet'
	end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

-- Create Font Function
lib.gen_fontstring = function(f, name, size, outline)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:SetFont(name, size, outline)
	fs:SetShadowColor(0,0,0,0.8)
	fs:SetShadowOffset(1,-1)
	return fs
end 

-- Create Health Bar Function
lib.addHealthBar = function(f)
	--statusbar
	local s = CreateFrame("StatusBar", nil, f)
	s:SetFrameLevel(1)
	s:SetHeight(retVal(f,f:GetHeight()*1,f:GetHeight()*.1,29))
	s:SetWidth(f:GetWidth())
	s:SetPoint("TOP",0,0)
	if f.mystyle=="raid" then
		s:SetStatusBarTexture(cfg.raid_texture)
	else
		s:SetStatusBarTexture(cfg.statusbar_texture)
	end
	s:GetStatusBarTexture():SetHorizTile(false)
    s:GetStatusBarTexture():SetVertTile(false)
	s:SetStatusBarColor(.1,.1,.1,1)
	--helper
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	if f.mystyle == "target" or f.mystyle == "player" then
		h:SetPoint("BOTTOMRIGHT",4,-4)
	elseif f.mystyle == "raid" then
		h:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 3.8, -4)
	else
		h:SetPoint("BOTTOMRIGHT", 4, -4)
	end
	lib.createBackdrop(h,0)
	--bg
	local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.statusbar_texture)
	b:SetAllPoints(s)
	b:SetVertexColor(.3,.3,.3)	
	f.Health = s
	f.Health.bg = b
end

--gen hp strings func
lib.addStrings = function(f)
    --health/name text strings
	local hpval, powerval, altppval, level
	f.Name = lib.gen_fontstring(f.Health, retVal(f,cfg.font,cfg.font,cfg.font), retVal(f,20,12,12), retVal(f,"OUTLINE","OUTLINE","OUTLINE"))
	f.Name:SetPoint(retVal(f,"TOPLEFT","LEFT","LEFT"), f.Health, retVal(f,"TOPLEFT","LEFT","LEFT"), retVal(f, 2, 2, 2), retVal(f, 24, 2, 0))
	f.Name:SetJustifyH("LEFT")
	f.Name.frequentUpdates = true
	level = lib.gen_fontstring(f.Health, cfg.font, 12, "OUTLINE")
	level:SetPoint("BOTTOMLEFT", f.Health, "BOTTOMLEFT", 2, -20)
	level:SetJustifyH("LEFT")
	hpval = lib.gen_fontstring(f.Health, cfg.font, retVal(f,15,12,13), retVal(f,"OUTLINE","OUTLINE","OUTLINE"))
	hpval:SetPoint(retVal(f,"TOPRIGHT","RIGHT","TOPLEFT"), f.Health, retVal(f,"TOPRIGHT","RIGHT","TOPLEFT"), retVal(f,-2,2,10), retVal(f,20,2,2))
	hpval.frequentUpdates = true
	if f.mystyle == "raid" then
		f.Name:SetPoint("RIGHT", f, "RIGHT", -1, 0)
		f:Tag(f.Name, "[Ambrosia:color][name][Ambrosia:raidafkdnd]")
	else
		f.Name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
		if f.mystyle == "player" then
			f:Tag(f.Name, "[Ambrosia:color][name]|r[Ambrosia:afkdnd]")
			f:Tag(powerval, "[my:power]")
			f:Tag(level, "[Ambrosia:level]")
		elseif f.mystyle == "target" then
			f:Tag(f.Name, "[Ambrosia:color][name][Ambrosia:afkdnd]")
			f:Tag(powerval, "[my:power]")
			f:Tag(level, "[Ambrosia:level]")
		else
			f:Tag(f.Name, "[Ambrosia:color][name]")
		end
	end
	f:Tag(hpval, retVal(f,"[Ambrosia:hp]","[Ambrosia:hp]","[Ambrosia:raidhp]"))
end

--gen powerbar func
lib.addPowerBar = function(f)
	--statusbar
	local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.powerbar_texture)
	s:GetStatusBarTexture():SetHorizTile(false)
	s:GetStatusBarTexture():SetVertTile(false)
	s:SetFrameLevel(1)
	if f.mystyle=="boss" then
		s:SetWidth(250)
		s:SetHeight(8)
		s:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,0)
		s:SetStatusBarColor(165/255, 73/255, 23/255, 1)
    else
        s:SetFrameLevel(4)
		s:SetHeight(retVal(f,f:GetHeight()*.26,f:GetHeight()*.2,2))
		s:SetWidth(f:GetWidth())
		local t = oUF.colors.class[playerClass]
		s:SetStatusBarColor(t[1], t[2], t[3], 1)
		if f.mystyle=="raid" then
			s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
		else
			s:SetPoint("BOTTOM",f,"BOTTOM",0,0)
		end
	end
	s.frequentUpdates = true
    --helper
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	if f.mystyle == "target" or f.mystyle == "player" or f.mystyle == "boss" then
		h:SetPoint("BOTTOMRIGHT",4,-4)
	elseif f.mystyle == "raid" then
		h:SetPoint("TOPLEFT",f,"TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT", 3.8, -4)
	else
		h:SetPoint("BOTTOMRIGHT", 4, -4)
	end
	lib.createBackdrop(h,0)
    --bg
    local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.powerbar_texture)
	b:SetAllPoints(s)
	b:SetVertexColor(.3,.3,.3)
    f.Power = s
    f.Power.bg = b
end

lib.addSecondaryPowerBar = function(f)
	local s = CreateFrame("Frame", nil, f)
	s:SetFrameLevel(1)
	
	local spec = GetSpecializationInfo(GetSpecialization())
	
	local maxPower = 0
	if playerClass == "ROGUE" then
		maxPower = MAX_COMBO_POINTS
	elseif playerClass == "MONK" then
		maxPower = 5
	elseif playerClass == "MAGE" and spec == 62 then
		maxPower = 4
	elseif playerClass == "PALADIN" then
		maxPower = UnitPowerMax('player', SPELL_POWER_HOLY_POWER)
	elseif playerClass == "DEATHKNIGHT" then
		maxPower = 6
	elseif playerClass == "WARLOCK" then
		maxPower = 4
	end
	
	for i = maxPower, 1, -1 do
		s[i] = CreateFrame("StatusBar", nil, s)
		s[i]:SetStatusBarTexture(cfg.powerbar_texture)
		s[i]:GetStatusBarTexture():SetHorizTile(false)

		if i == maxPower then
			s[i]:SetPoint("RIGHT", s)
		else
			s[i]:SetPoint("RIGHT", s[i+1], "LEFT", -10, 0)
		end

		s[i]:SetWidth(((cfg.secondarypowerWidth)-(maxPower - 10))/ maxPower)
		s[i]:SetHeight(cfg.secondarypowerHeight)
		s[i]:SetFrameLevel(4)
		local t = oUF.colors.class[playerClass]
		s[i]:SetStatusBarColor(t[1], t[2], t[3], 1)
		
		local h = CreateFrame("Frame", nil, s[i])
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT", 4, -4)
		lib.createBackdrop(h,0)
		--bg
		local b = s[i]:CreateTexture(nil, "BACKGROUND")
		b:SetTexture(cfg.powerbar_texture)
		b:SetAllPoints(s[i])
		b:SetVertexColor(.3,.3,.3)
	end
	
	if playerClass == "ROGUE" then
		f.CPoints = s
	elseif playerClass == "MONK" then
		f.MonkHarmonyBar = s
		f.MonkHarmonyBar.PreUpdate = function()
			local currMaxPower = UnitPowerMax("player",SPELL_POWER_CHI)
			for i = 1, 5 do
				s[i]:SetWidth(((cfg.secondarypowerWidth)-(currMaxPower - 1))/ currMaxPower) 
			end
		end
	elseif playerClass == "MAGE" and spec == 62 then
		f.ArcaneCharges = s
	elseif playerClass == "PALADIN" then
		f.PaladinHolyPower = s
	elseif playerClass == "DEATHKNIGHT" then
		f.Runes = s
	elseif playerClass == "WARLOCK" then
		f.WarlockSpecBars = s
	end
		
	f.SecondaryPower = s
end

lib.createBuffs = function(f)
    b = CreateFrame("Frame", nil, f)
	b.size = 20
    b.spacing = 8
    b.onlyShowPlayer = cfg.buffsOnlyShowPlayer
    if f.mystyle == "player" then
	    b.size = 35
		b.num = 30
		b:SetHeight((b.size+b.spacing)*3)
		b:SetWidth((b.size+b.spacing)*10)
		b:SetPoint("TOPLEFT", UIParent,  26, -40)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"
    elseif f.mystyle == "target" then
	    b.size = 21
		b.num = 18
		b:SetHeight((b.size+b.spacing)*2)
		b:SetWidth((b.size+b.spacing)*9)
		b:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -30)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"		
	else
		b.num = 0
    end
    b.PostCreateIcon = lib.postCreateIcon
    b.PostUpdateIcon = lib.postUpdateIcon

    f.Buffs = b
end

lib.createDebuffs = function(f)
    b = CreateFrame("Frame", nil, f)
    b.size = 20
	b.spacing = 8
	b.onlyShowPlayer = cfg.debuffsOnlyShowPlayer
	if f.mystyle == "player" then
	    b.size = 35
		b.num = 30
		b:SetHeight((b.size+b.spacing)*3)
		b:SetWidth((b.size+b.spacing)*10)
		b:SetPoint("TOPLEFT", UIParent, 26,-180)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"
	elseif f.mystyle == "target" then
	    b.size = 21
		b.num = 18
		b:SetHeight((b.size+b.spacing)*2)
		b:SetWidth((b.size+b.spacing)*9)
		b:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -90)
		b.initialAnchor = "TOPLEFT"
		b["growth-x"] = "RIGHT"
		b["growth-y"] = "DOWN"		
	else
		b.num = 0
	end
	
	b.PostCreateIcon = lib.postCreateIconDebuff
	b.PostUpdateIcon = lib.postUpdateIcon
	
    f.Debuffs = b
end

lib.postCreateIcon = function(buffs, button)
	local diffPos = 0
	local self = buffs:GetParent()
	if self.mystyle == "target" then diffPos = 0 end
	
	buffs.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	
	local h = CreateFrame("Frame", nil, button)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	frame1px1(h)
	CreateShadow(h)
	
	local time = lib.gen_fontstring(button, cfg.font, 12, "OUTLINE")
	time:SetPoint("BOTTOM", button, "BOTTOM", 1, 0)
	time:SetJustifyH("CENTER")
	time:SetVertexColor(1,1,1)
	button.time = time
	
	local count = lib.gen_fontstring(button, cfg.font, 12, "OUTLINE")
	count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 2)
	count:SetJustifyH("RIGHT")
	button.count = count
	GameTooltip:Show()
	button.UpdateTooltip = updateTooltip
	
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer("ARTWORK")
end

lib.postUpdateIcon = function(buffs, unit, icon, index, offset)
	local _, _, _, _, _, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
	
	if duration and duration > 0 then
		icon.time:Show()
		icon.timeLeft = expirationTime	
		icon:SetScript("OnUpdate", setTimer)			
	else
		icon.time:Hide()
		icon.timeLeft = math.huge
		icon:SetScript("OnUpdate", nil)
	end
	-- Desaturate non-Player Debuffs
	if(icon.debuff) then
	print("desaturate fired")
		if(unit == "target") then	
			if (unitCaster == "player" or unitCaster == "vehicle") then
				icon.icon:SetDesaturated(false)				
			elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don"t desaturate debuffs
				icon:SetBackdropColor(0, 0, 0)
				icon.overlay:SetVertexColor(0.3, 0.3, 0.3)      
				icon.icon:SetDesaturated(true)  			
			end
		end
	end
	icon:SetScript('OnMouseUp', function(self, mouseButton)
		if mouseButton == 'RightButton' then
			CancelUnitBuff('player', index)
	end end)
	icon.first = true
end

lib.postCreateIconDebuff = function(element, button)
	local diffPos = 0
	local self = element:GetParent()
	if self.mystyle == "target" then diffPos = 0 end
	
	element.disableCooldown = true
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	
	local h = CreateFrame("Frame", nil, button)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-5,5)
	h:SetPoint("BOTTOMRIGHT",5,-5)
	frame1px1red(h)
	CreateShadow(h)
	
	local time = lib.gen_fontstring(button, cfg.font, 12, "OUTLINE")
	time:SetPoint("BOTTOM", button, "BOTTOM", 1, 0)
	time:SetJustifyH("CENTER")
	time:SetVertexColor(1,1,1)
	button.time = time
	
	local count = lib.gen_fontstring(button, cfg.font, 12, "OUTLINE")
	count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 4, 2)
	count:SetJustifyH("RIGHT")
	button.count = count
	GameTooltip:Show()
	button.UpdateTooltip = updateTooltip
	
	button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon:SetDrawLayer("ARTWORK")			
end

lib.updateInfoIcons = function(f)
	local icons = nil
	for i, icon in pairs({ f.Combat, f.Resting, f.PvP, f.Assistant, f.Leader }) do
		if icon and icon:IsShown() then
			icons = { next = icons, value = icon }
		end
	end
	
	if not icons then return end
	
	icons.value:SetPoint('RIGHT', f.Name, 'RIGHT', -5, 0)
	while icons.next do
		icons.next.value:SetPoint('RIGHT', icons.value, 'RIGHT', -20, 0)
		icons = icons.next
	end
end

lib.gen_InfoIcons = function(f)
    local h = CreateFrame("Frame",nil,f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
	co = h:CreateTexture(nil, 'OVERLAY')
	co:SetTexture[[Interface\CharacterFrame\UI-StateIcon]]
	co:SetTexCoord(0.55, 0.9, 0.05, 0.4)
	co:SetSize(15, 15)
	f.Combat = co
    li = h:CreateTexture(nil, "OVERLAY")
	li:SetSize(15, 15)
    f.Leader = li
    ai = h:CreateTexture(nil, "OVERLAY")
	ai:SetSize(15, 15)
    f.Assistant = ai
	re = h:CreateTexture(nil, "OVERLAY")
	re:SetSize(15, 15)
	f.Resting = re
	pvp = h:CreateTexture(nil, "OVERLAY")
	pvp:SetTexCoord(0, 0.6, 0, 0.6)
	pvp:SetSize(15, 15)
	f.PvP = pvp
	
	f.Combat.PostUpdate = function() lib.updateInfoIcons(f) end
	f.Leader.PostUpdate = function() lib.updateInfoIcons(f) end
	f.Assistant.PostUpdate = function() lib.updateInfoIcons(f) end
	f.Resting.PostUpdate = function() lib.updateInfoIcons(f) end
	f.PvP.PostUpdate = function() lib.updateInfoIcons(f) end
end

lib.createStaggerBar = function(f)
	local spec = GetSpecializationInfo(GetSpecialization())
	if spec ~= 268 then return end
	
	local s = CreateFrame("StatusBar", nil, f)
	s:SetFrameLevel(1)
	s:SetHeight(f:GetHeight())
	s:SetWidth(f:GetWidth()*0.3)
	s:SetPoint("TOPRIGHT",0,50)
	s:SetStatusBarTexture(cfg.statusbar_texture)
	s:GetStatusBarTexture():SetHorizTile(false)
    s:GetStatusBarTexture():SetVertTile(false)
	--helper
	local h = CreateFrame("Frame", nil, s)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-4,4)
	h:SetPoint("BOTTOMRIGHT",4,-4)
	lib.createBackdrop(h,0)
	--bg
	local b = s:CreateTexture(nil, "BACKGROUND")
	b:SetTexture(cfg.statusbar_texture)
	b:SetAllPoints(s)
	b:SetVertexColor(.3,.3,.3)
	
	staggerval = lib.gen_fontstring(f, cfg.font, 15, "OUTLINE")
	staggerval:SetPoint("RIGHT", s, "LEFT", -5, 0)
	staggerval.frequentUpdates = true
	
	f:Tag(staggerval, "[Ambrosia:stagger]")
		
	f.Stagger = s
end

lib.createExpTags = function(f)	
	local maxLevel = UnitLevel("player") == 90
	
	if maxLevel then
		repval = lib.gen_fontstring(f, cfg.font, 15, "OUTLINE")
		repval:SetPoint('Right', f, 'LEFT', -10, 0)
		
		f:Tag(repval, "[Ambrosia:rep]")
	else
		xpval = lib.gen_fontstring(f, cfg.font, 15, "OUTLINE")
		xpval:SetPoint('RIGHT', f, 'LEFT', -10, 0)
		
		restval = lib.gen_fontstring(f, cfg.font, 15, "OUTLINE")
		restval:SetPoint('RIGHT', f, 'LEFT', -10, -20)
		
		repval = lib.gen_fontstring(f, cfg.font, 15, "OUTLINE")
		repval:SetPoint('Right', f, 'LEFT', -10, -40)
			
		f:Tag(xpval, "[Ambrosia:xp]")
		f:Tag(restval, "[Ambrosia:rest]")
		f:Tag(repval, "[Ambrosia:rep]")
	end
end

-----------------------------
-- HANDOVER
-----------------------------

ns.lib = lib
