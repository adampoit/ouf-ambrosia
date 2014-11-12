if select(2, UnitClass("player")) ~= "MAGE" then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "ArcaneCharges was unable to locate oUF install")

local ARCANE_CHARGES = 4
local curMaxPower = 0

local Update = function(self, event, unit, powerType)
	if(self.unit ~= unit or (powerType and powerType ~= "ARCANE_CHARGES")) then return end

	local ac = self.ArcaneCharges
	if(ac.PreUpdate) then ac:PreUpdate(unit) end
	
	local _, _, _, count = UnitDebuff("player","Arcane Charge")
	local power = count or 0

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