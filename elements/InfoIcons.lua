local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "InfoIcons was unable to locate oUF install")

local Update = function(self, event, unit)
	if(self.unit ~= unit or (powerType and powerType ~= "ARCANE_CHARGES")) then return end

	local ii = self.InfoIcons
	if(ii.PreUpdate) then ii:PreUpdate(unit) end
	
	local isLeader = (UnitInParty(unit) or UnitInRaid(unit)) and UnitIsGroupLeader(unit)
	local isAssistant = UnitInRaid(unit) and UnitIsGroupAssistant(unit) and not UnitIsGroupLeader(unit)
	
	local pvpStatus
	local factionGroup = UnitFactionGroup(unit)
	if(UnitIsPVPFreeForAll(unit)) then
		pvp:SetTexture[[Interface\TargetingFrame\UI-PVP-FFA]]
		pvpStatus = 'ffa'
	-- XXX - WoW5: UnitFactionGroup() can return Neutral as well.
	elseif(factionGroup and factionGroup ~= 'Neutral' and UnitIsPVP(unit)) then
		pvp:SetTexture([[Interface\TargetingFrame\UI-PVP-]]..factionGroup)
		pvpStatus = factionGroup
	end

	for i = 1,ARCANE_CHARGES do
		if i <= power then
			ac[i]:Show()
		else
			ac[i]:Hide()
		end
	end
	
	if(ac.PostUpdate) then
		return ac:PostUpdate(spec)
	end
end

local Path = function(self, ...)
	return (self.ArcaneCharges.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit, "ARCANE_CHARGES")
end

local function Enable(self)
	local ac = self.ArcaneCharges
	if(ac) then
		ac.__owner = self
		ac.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_AURA", Path)

		for i = 1, ARCANE_CHARGES do
			local charge = ac[i]
			if not charge:GetStatusBarTexture() then
				charge:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end
			
			charge:SetFrameLevel(ac:GetFrameLevel() + 1)
			charge:GetStatusBarTexture():SetHorizTile(false)
		end
		
		return true
	end
end

local function Disable(self)
	local ac = self.ArcaneCharges
	if(ac) then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("ArcaneCharges", Path, Enable, Disable)