ENT.Type = 'ai'
ENT.Base = 'base_ai'
ENT.PrintName = 'npc_bail'
ENT.Author = ''
ENT.Category = "Jail NPC"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.CanUse = true

target = target or {}

function GetTarget()
	return target or {}
end

function ENT:InitVars()
	self.CoolDown = 3

	self.CanUse = true
	self.NextUse = CurTime()

	if( CLIENT )then return end

	util.AddNetworkString( 'open_bail_menu' )
end

if( SERVER )then AddCSLuaFile() end