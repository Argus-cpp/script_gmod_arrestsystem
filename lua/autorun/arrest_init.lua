if SERVER then AddCSLuaFile('arrest_config.lua') util.AddNetworkString('jail_system') util.AddNetworkString('jail_msg') util.AddNetworkString('send_table') end

include('arrest_config.lua')

local meta = FindMetaTable('Player')

function meta:setBailPrice( amount )
	self:SetNWInt('bail_price', amount or 0)
end

function meta:getBailPrice()
	return self:GetNWInt('bail_price') or nil
end

function meta:setJailReason( reason )
	self:SetNWString('jail_reason', reason)
end

function meta:getJailReason()
	return self:GetNWString('jail_reason')
end

hook.Add('PlayerSay', 'bail_player', function(pl, txt)
	local args = string.Explode(' ', txt)
	if table.HasValue(ARREST_COMMAND, args[1]) and ARREST_ENABLE_CHATCOMMAND then
		if (args[2] == nil) then pl:SendLua("chat.AddText(ARREST_PREFIXCOLOR, ARREST_PREFIX, Color(255,255,255), ' Ошибка! Пишите ', Color(0,255,0), table.Random(ARREST_COMMAND)..' ник')") return '' end 
		local isFound = false
		local ent = nil
		for _, v in pairs(player.GetAll())do
			if v:Nick() == args[2] then ent = v isFound = true break end
		end
		if isFound then 
			if ent:getJailReason() == 'nil' then pl:ChatPrint(ent:Nick().." not arrested!") return '' end
			if !pl:canAfford(ent:getBailPrice()) then pl:ChatPrint("Not enought money! Need "..ent:getBailPrice()..ARREST_MONEYPREFIX) return '' end
			pl:addMoney(-ent:getBailPrice())
			pl:ChatPrint("Вы заплатили залог за "..ent:Nick().." в размере "..DarkRP.formatMoney(ent:getBailPrice()))
			ent:ChatPrint(pl:Nick().." заплатил за вас залог в размере "..DarkRP.formatMoney(ent:getBailPrice()))

			ent:unArrest(pl)
			ent:setJailReason('nil')
		else
			pl:SendLua("chat.AddText(ARREST_PREFIXCOLOR, ARREST_PREFIX, Color(255,255,255), ' игрок не найден!!')")
		end

		return ''
	end
end)

if CLIENT then
	net.Receive('send_table', function()
		local tbl = net.ReadTable()
		ARREST_BAILLIST = tbl or {}
	end)
end