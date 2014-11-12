-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
  
local cfg = ns.cfg
local lib = ns.lib

-----------------------
-- Style Functions
-----------------------

local UnitSpecific = {

	player = function(self, ...)
	
		self.mystyle = "player"
		
		-- Size and Scale
		self:SetScale(1)
		self:SetWidth(cfg.unitframeWidth)
		self:SetHeight(cfg.unitframeHeight)
		
		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.addPowerBar(self)
		lib.gen_InfoIcons(self)
		lib.addSecondaryPowerBar(self)
		lib.createBuffs(self)
		lib.createDebuffs(self)		
		lib.createStaggerBar(self)
		lib.createExpTags(self)
		
        -- healthbar/powerbar
        self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
		self.Health:SetSize(cfg.unitframeWidth, cfg.unitframeHeight)
		self.Health.frequentUpdates = true
		
		self.Power:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', cfg.unitframeWidth - cfg.powerWidth, -(cfg.unitframeHeight - cfg.powerHeight + 15))
		self.Power:SetSize(cfg.powerWidth, cfg.powerHeight)
		self.Power.frequentUpdates = true
		
		self.SecondaryPower:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOM', cfg.secondarypowerX, cfg.secondarypowerY)
		self.SecondaryPower:SetSize(cfg.secondarypowerWidth, cfg.secondarypowerHeight)
		
		-- oUF_Smooth
		self.Health.Smooth = true
		self.Power.Smooth = true
       
		-- Event Handlers
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)
		
	end,
	target = function(self, ...)
	
		self.mystyle = "target"
		
		-- Size and Scale
		self:SetScale(1)
		self:SetWidth(cfg.unitframeWidth)
		self:SetHeight(cfg.unitframeHeight)
		
		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)
		lib.createBuffs(self)
		lib.createDebuffs(self)
		
        -- healthbar/powerbar
        self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
		self.Health:SetSize(cfg.unitframeWidth, cfg.unitframeHeight)
		self.Health.frequentUpdates = true
		
		-- oUF_Smooth
		self.Health.Smooth = true
       
		-- Event Handlers
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", cfg.updateSpec)
		
	end,
	targettarget = function(self, ...)

		self.mystyle = "tot"
		
		-- Size and Scale
		self:SetScale(1)
		self:SetWidth(120)
		self:SetHeight(21)
        
		-- Generate Bars
		lib.addHealthBar(self)
		lib.addStrings(self)

		self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
		self.Health:SetSize(120, 21)
		self.Health.frequentUpdates = true
		
		-- oUF_Smooth
		self.Health.Smooth = true
		
	end,
}


-----------------------
-- Register Styles
-----------------------

-- Global Style
local GlobalStyle = function(self, unit, isSingle)
	self.menu = lib.spawnMenu
	self:RegisterForClicks('AnyUp')
	
	-- Call Unit Specific Styles
	if (UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	end
end

-- Boss Style
local BossStyle = function(self, unit)
	self.mystyle="boss"
	
	-- Size and Scale
	self:SetScale(1)
	self:SetSize(120, 21)
    
	-- Generate Bars
	lib.addHealthBar(self)
	lib.addStrings(self)

	self.Health:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
	self.Health:SetSize(120, 21)
	self.Health.frequentUpdates = true
	
	-- oUF_Smooth
	self.Health.Smooth = true
end

-----------------------
-- Spawn Frames
-----------------------

oUF:RegisterStyle('AmbrosiaGlobal', GlobalStyle)
oUF:RegisterStyle('AmbrosiaBoss', BossStyle)

oUF:Factory(function(self)
	-- Single Frames
	self:SetActiveStyle('AmbrosiaGlobal')

	self:Spawn('player'):SetPoint("BOTTOMRIGHT",UIParent,"BOTTOM", cfg.playerX, cfg.playerY)
	self:Spawn('target'):SetPoint("BOTTOMLEFT",UIParent,"BOTTOM", cfg.targetX, cfg.targetY)
	self:Spawn('targettarget'):SetPoint("BOTTOMLEFT",UIParent,"BOTTOM", cfg.totX, cfg.totY)
	
	self:SetActiveStyle('AmbrosiaBoss')
	
	self:Spawn("boss1", "oUF_Boss1"):SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -75, 425)
	self:Spawn("boss2", "oUF_Boss2"):SetPoint("BOTTOMRIGHT", oUF_Boss1, "TOPRIGHT", 0, 8)
	self:Spawn("boss3", "oUF_Boss3"):SetPoint("BOTTOMRIGHT", oUF_Boss2, "TOPRIGHT", 0, 8)
	self:Spawn("boss4", "oUF_Boss4"):SetPoint("BOTTOMRIGHT", oUF_Boss3, "TOPRIGHT", 0, 8)
	self:Spawn("boss5", "oUF_Boss5"):SetPoint("BOTTOMRIGHT", oUF_Boss4, "TOPRIGHT", 0, 8)
	self:Spawn("boss6", "oUF_Boss6"):SetPoint("BOTTOMRIGHT", oUF_Boss5, "TOPRIGHT", 0, 8)
end)

oUF:DisableBlizzard('party')
