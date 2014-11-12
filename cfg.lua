-----------------------------
-- INIT
-----------------------------

local addon, ns = ...
local cfg = CreateFrame("Frame")

-----------------------------
-- CONFIG
-----------------------------

--unitframes
	cfg.unitframeWidth = 400
	cfg.unitframeHeight = 17
	cfg.unitframeScale = 1 -- Keep between 1 and 1.25 to have a good result, 1 = standard
	cfg.powerWidth = 350
	cfg.powerHeight = 10
--player
	cfg.playerX = -200 -- x-coordinate of the player frame
	cfg.playerY = 425 -- y-coordinate of the player frame
--target
	cfg.targetX = 200
	cfg.targetY = 425
--tot
	cfg.totX = 615
	cfg.totY = 425
--secondarypower
	cfg.secondarypowerX = -200
	cfg.secondarypowerY = 380
	cfg.secondarypowerWidth = 250
	cfg.secondarypowerHeight = 10
-- toggle Blizzard-Frames
    cfg.hideBuffFrame = true -- (De-)Buffs on Player/Target/Pet/etc
    cfg.hideWeaponEnchants = true -- WeaponEnchants, e.g. Deadly Poison 
    cfg.hideRaidFrame = true -- raidframe
    cfg.hideRaidFrameContainer = false -- Frame to set raidmarks, those shiny marks on the ground and so on
	
--media files
	cfg.font = "Interface\\AddOns\\oUF_Ambrosia\\media\\fonts\\font.ttf"
	
	cfg.statusbar_texture = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\normTex"
	cfg.powerbar_texture = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\normTex"
	cfg.raid_texture = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\normTex"
	cfg.backdrop_texture = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\backdrop"
	cfg.backdrop_edge_texture = "Interface\\AddOns\\oUF_Ambrosia\\media\\textures\\backdrop_edge"
	
--do not change this
	cfg.spec = nil
	cfg.updateSpec = function()
		cfg.spec = GetSpecialization()
	end
	
-----------------------------
-- HANDOVER
-----------------------------

ns.cfg = cfg
