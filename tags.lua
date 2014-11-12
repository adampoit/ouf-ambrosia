-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = ns.cfg

local tags = oUF.Tags

local SVal = function(val)
	if val then
		if (val >= 1e6) then
			return ("%.1fm"):format(val / 1e6)
		elseif (val >= 1e3) then
			return ("%.1fk"):format(val / 1e3)
		else
			return ("%d"):format(val)
		end
	end
end

local function hex(r, g, b)
	if r then
		if (type(r) == "table") then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end
end

local function GetReputation()
	local name, standing, min, max, value, id = GetWatchedFactionInfo()
	local _, friendMin, friendMax, _, _, _, friendStanding, friendThreshold = GetFriendshipReputation(id)

	if(not friendMin) then
		return value - min, max - min, GetText('FACTION_STANDING_LABEL' .. standing, UnitSex('player'))
	else
		return friendMin - friendThreshold, math.min(friendMax - friendThreshold, 8400), friendStanding
	end
end

tags.Events["Ambrosia:perhp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["Ambrosia:perhp"] = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return ("%s%%"):format(math.floor((UnitHealth(u)/m*100+.05)*10)/10)
	end
end

tags.Events["Ambrosia:hp"] = 'UNIT_HEALTH UNIT_MAXHEALTH'
tags.Methods["Ambrosia:hp"] = function(u)
	local ddg = _TAGS["Ambrosia:DDG"](u)
	
	if ddg then
		return ddg
	else
		local per = _TAGS["Ambrosia:perhp"](u) or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if u == "player" or u == "target" then
			if min~=max then 
				return ("|cffffaaaa%s|r | %s"):format(SVal(min), per)
			else
				return ("%s | %s"):format(SVal(max), per)
			end
		else
			return per
		end
	end
end

tags.Events["Ambrosia:perstagger"] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_STAGGER'
tags.Methods["Ambrosia:perstagger"] = function(u)
	local m = UnitHealthMax(u)
	local s = UnitStagger(u)
	if(m == 0) then
		return 0
	else
		return ("%s%%"):format(math.floor((s/m*100+.05)*10)/10)
	end
end

tags.Events["Ambrosia:stagger"] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_STAGGER'
tags.Methods["Ambrosia:stagger"] = function(u)
	local stagger = UnitStagger(u)
	local per = _TAGS["Ambrosia:perstagger"](u) or 0
	
	return ("%s | %s"):format(SVal(stagger), per)
end

tags.Events["Ambrosia:xp"] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
tags.Methods["Ambrosia:xp"] = function(u)
	return ("%s XP"):format(_TAGS["Ambrosia:perxp"](u) or 0)
end

tags.Events["Ambrosia:perxp"] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
tags.Methods["Ambrosia:perxp"] = function(u)
	return ("%s%%"):format(math.floor(UnitXP(u) / UnitXPMax(u) * 100 + 0.5))
end

tags.Events["Ambrosia:rest"] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
tags.Methods["Ambrosia:rest"] = function(u)
	return ("%s Rested"):format(_TAGS["Ambrosia:perrest"](u) or 0)
end

tags.Events["Ambrosia:perrest"] = 'PLAYER_XP_UPDATE PLAYER_LEVEL_UP UPDATE_EXHAUSTION'
tags.Methods["Ambrosia:perrest"] = function(u)
	local rested = GetXPExhaustion()
	return ("%s%%"):format(math.floor((rested or 0) / UnitXPMax(u) * 100 + 0.5))
end

tags.Events["Ambrosia:rep"] = 'UPDATE_FACTION'
tags.Methods["Ambrosia:rep"] = function(u)
	local _, _, standing = GetReputation()
	local _, standingID = GetWatchedFactionInfo()
	local color = FACTION_BAR_COLORS[standingID]
	if not color then return end
	
	return ("%s%s %s"):format(hex(color.r, color.g, color.b), _TAGS["Ambrosia:perrep"](u) or 0, standing)
end

tags.Events["Ambrosia:perrep"] = 'UPDATE_FACTION'
tags.Methods["Ambrosia:perrep"] = function(u)
	local min, max = GetReputation()
	return ("%s%%"):format(math.floor(min / max * 100 + 1/2))
end

tags.Events["Ambrosia:color"] = 'UNIT_REACTION UNIT_HEALTH UNIT_HAPPINESS'
tags.Methods["Ambrosia:color"] = function(u)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")
	
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return "|cffA0A0A0"
	elseif (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
		return hex(oUF.colors.tapped)
	elseif (u == "pet") then
		return hex(oUF.colors.class[class])
	elseif (UnitIsPlayer(u)) then
		return hex(oUF.colors.class[class])
	elseif reaction then
		return hex(oUF.colors.reaction[reaction])
	else
		return hex(1, 1, 1)
	end
end

tags.Events["Ambrosia:afkdnd"] = 'PLAYER_FLAGS_CHANGED'
tags.Methods["Ambrosia:afkdnd"] = function(unit) 
	return UnitIsAFK(unit) and "|cffCFCFCF <afk>|r" or UnitIsDND(unit) and "|cffCFCFCF <dnd>|r" or ""
end

tags.Events["Ambrosia:raidafkdnd"] = 'PLAYER_FLAGS_CHANGED'
tags.Methods["Ambrosia:raidafkdnd"] = function(unit) 
	return UnitIsAFK(unit) and "|cffCFCFCF AFK|r" or UnitIsDND(unit) and "|cffCFCFCF DND|r" or ""
end

tags.Events["Ambrosia:DDG"] = 'UNIT_HEALTH'
tags.Methods["Ambrosia:DDG"] = function(u)
	if UnitIsDead(u) then
		return "|cffCFCFCF Dead|r"
	elseif UnitIsGhost(u) then
		return "|cffCFCFCF Ghost|r"
	elseif not UnitIsConnected(u) then
		return "|cffCFCFCF Off|r"
	end
end

tags.Events["Ambrosia:perhpboss"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED'
tags.Methods["Ambrosia:perhpboss"] = function(u)
	local m = UnitHealthMax(u)
	if(m == 0) then
		return 0
	else
		return ("%s%%"):format(math.floor((UnitHealth(u)/m*100+.05)*10)/10)
	end
end

tags.Events["Ambrosia:hpboss"] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED'
tags.Methods["Ambrosia:hpboss"] = function(u)
	local ddg = _TAGS["Ambrosia:DDG"](u)
	
	if ddg then
		return ddg
	else
		local per = _TAGS["Ambrosia:perhpboss"](u) or 0
		local min, max = UnitHealth(u), UnitHealthMax(u)
		if u == "player" or u == "target" then
			if min~=max then 
				return ("|cffffaaaa%s|r/%s | %s"):format(SVal(min), SVal(max), per)
			else
				return ("%s | %s"):format(SVal(max), per)
			end
		else
			return per
		end
	end
end

tags.Events["Ambrosia:nameboss"] = 'UNIT_NAME_UPDATE UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED'
tags.Methods["Ambrosia:nameboss"] = function(u, r)
	return UnitName(r or u)
end

--end fix for boss bar update
tags.Events["Ambrosia:raidhp"] = 'UNIT_HEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
tags.Methods["Ambrosia:raidhp"] = function(u) 
	local ddg = _TAGS["Ambrosia:DDG"](u)
	
	if ddg then
		return ddg
	else
		local missinghp = SVal(_TAGS["missinghp"](u)) or ""
		if missinghp ~= "" then
			return ("-%s"):format(missinghp)
		else
			return ""
		end
	end
end

tags.Events["my:power"] = 'UNIT_MAXPOWER UNIT_POWER UPDATE_SHAPESHIFT_FORM'
tags.Methods["my:power"] = function(unit)
	local curpp, maxpp = UnitPower(unit), UnitPowerMax(unit);
	local playerClass, englishClass = UnitClass(unit);

	if(maxpp == 0) then
		return ""
	else
		if (englishClass == "WARRIOR") then
			return curpp
		elseif (englishClass == "DEATHKNIGHT" or englishClass == "ROGUE" or englishClass == "HUNTER") then
			return ("%s/%s"):format(curpp, maxpp)
		else
			return ("%s | %s%%"):format(SVal(curpp), math.floor(curpp/maxpp*100+0.5))
		end
	end
end

tags.Events["Ambrosia:level"] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'
tags.Methods["Ambrosia:level"] = function(unit)
	
	local c = UnitClassification(unit)
	local l = UnitLevel(unit)
	local d = GetQuestDifficultyColor(l)
	
	local str = l
		
	if l <= 0 then l = "??" end
	
	if c == "worldboss" then
		str = string.format("|cff%02x%02x%02xBoss|r",250,20,0)
	elseif c == "eliterare" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r+",d.r*255,d.g*255,d.b*255,l)
	elseif c == "elite" then
		str = string.format("|cff%02x%02x%02x%s|r+",d.r*255,d.g*255,d.b*255,l)
	elseif c == "rare" then
		str = string.format("|cff%02x%02x%02x%s|r|cff0080FFR|r",d.r*255,d.g*255,d.b*255,l)
	else
		if not UnitIsConnected(unit) then
			str = "??"
		else
			if UnitIsPlayer(unit) then
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			elseif UnitPlayerControlled(unit) then
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			else
				str = string.format("|cff%02x%02x%02x%s",d.r*255,d.g*255,d.b*255,l)
			end
		end		
	end
	
	return str
end
