if SERVER then return end

include( 'shared.lua' )

surface.CreateFont("bolder_font", {
	font = "Arial",
	size = 150,
	weight = 500
})

function ENT:Initialize()
	self:DrawModel()
	self:InitVars()
end

function ENT:Draw()
	self:DrawModel()

	if(self:GetPos():DistToSqr( LocalPlayer():GetPos() ) <= 2250)then

		local hop = math.abs(math.cos(CurTime() * 1))
		local ent = self

		local pos = ent:GetPos() + Vector( 0, 0, 95 + hop * 15 )
		local ang = Angle( 0, LocalPlayer():EyeAngles().y - 90, 90 )

		cam.Start3D2D( pos, ang, 0.1 )
	 		draw.SimpleText( '' .. ARREST_NPC_NAME .. '', 'bolder_font', 0, 0, ARREST_NPC_NAMECOLOR, 1 )
		cam.End3D2D()
	end
end

net.Receive('open_bail_menu', function()
	local frame = vgui.Create('DFrame')
	frame:SetSize(400,400)
	frame:Center()
	frame:SetTitle('')
	frame:MakePopup()
	frame.Paint = function(self,w,h)
		draw.RoundedBox(5,0,0,w,h,Color(0,0,0,200))
		draw.RoundedBox(5,0,0,w,25,Color(0,0,255,150))
		draw.SimpleText(ARREST_NPC_PANELTITLE, "Trebuchet24", w/2, 1, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local DScroll = vgui.Create('DScrollPanel', frame)
	DScroll:Dock(FILL)

	for k, pl in pairs(ARREST_BAILLIST) do
		local list = DScroll:Add('DPanel')
		list:Dock(TOP)
		list:DockMargin(1, 0, 1, 6)
		list:SetTall(35)
		list.Paint = function(self,w,h)
			draw.RoundedBox(5,0,0,w,h,Color(0,0,0,200))
			draw.SimpleText(pl:Nick().." ("..pl:getBailPrice()..ARREST_MONEYPREFIX..")", "Trebuchet24", 3, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		local Buy = vgui.Create("DPanel", list)
		Buy:Dock(RIGHT)
		Buy:DockMargin(2,2,2,2)
		Buy:SetWide(80)
		Buy.Paint = function(self,w,h)
			if !self:IsHovered() then
				draw.RoundedBox(5,0,0,w,h,Color(0,0,200,100))
			else
				draw.RoundedBox(5,0,0,w,h,Color(0,0,200,230))
				self:SetCursor('hand')
			end
			draw.SimpleText(ARREST_NPC_PAILBUY, "Trebuchet24", w/2,h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		Buy.OnMousePressed = function()
			net.Start('bail_player_now')
				net.WriteEntity(pl)
			net.SendToServer()
			frame:Remove()
		end
	end
end)