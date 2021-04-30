if CLIENT then return end
include( 'shared.lua' )

AddCSLuaFile( 'cl_init.lua' )
util.AddNetworkString('bail_player_now')

local wait = wait or {}
local npcclass = 'npc_courier'

function ENT:Initialize()
	self:InitVars()
	self:DontDeleteOnRemove( self )
	self.CanUse = true
	self:SetModel( ARREST_NPC_MODEL )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid( SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE + CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	self:SetSequence( 4 )
	self:SetTrigger( true )
end

local cleanup = game.CleanUpMap
function game.CleanUpMap(send,flr)
	if !flr then flr = {} end
	if !table.HasValue(flr,npcclass) then
		flr[#flr+1] = npcclass --after cleanup, insert npc in table
	end
	cleanup(send,flr)
end

function ENT:OnRemove()
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:AcceptInput( name, ent, ply )
	if( name == "Use" and IsValid( ply ) and ply:IsPlayer() and ply:Alive() )then
		if( self.NextUse <= CurTime() )then
			self.NextUse = CurTime() + self.CoolDown

			net.Start( 'open_bail_menu' )
				net.WriteEntity( self )
			net.Send( ply )

		end
	end
end

net.Receive('bail_player_now', function(ln,pl)
	local ent = net.ReadEntity()
	if !table.HasValue(ARREST_BAILLIST, ent) then return end
	if ent:getJailReason() == 'nil' then pl:ChatPrint(ent:Nick().." не арестован!") return '' end
	if !pl:canAfford(ent:getBailPrice()) then pl:ChatPrint("Not enought money! Need "..ent:getBailPrice()..ARREST_MONEYPREFIX) return '' end
	pl:addMoney(-ent:getBailPrice())
	pl:ChatPrint("Ты внес залог за "..ent:Nick().." в размере "..ent:getBailPrice()..ARREST_MONEYPREFIX)
	ent:ChatPrint(pl:Nick().." внес за Вас залог в размере "..ent:getBailPrice()..ARREST_MONEYPREFIX)

	ent:unArrest(pl)
	ent:setJailReason('nil')
	table.RemoveByValue(ARREST_BAILLIST, ent) 
    net.Start('send_table')
        net.WriteTable(ARREST_BAILLIST)
    net.Broadcast()
end)	