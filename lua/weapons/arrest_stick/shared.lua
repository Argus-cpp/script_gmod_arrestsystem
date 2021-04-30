AddCSLuaFile()
include('arrest_config.lua')

if CLIENT then
    SWEP.PrintName = "Арестовывающая дубинка"
    SWEP.Slot = 1
    SWEP.SlotPos = 3
end

DEFINE_BASECLASS("stick_base")

SWEP.Instructions = "ЛКМ - арест\n"
SWEP.IsDarkRPArrestStick = true

SWEP.Spawnable = true
SWEP.Category = "ExclusiveRP"

SWEP.StickColor = Color(255, 0, 0)

SWEP.Switched = true

DarkRP.hookStub{
    name = "canArrest",
    description = "Whether someone can arrest another player.",
    parameters = {
        {
            name = "arrester",
            description = "The player trying to arrest someone.",
            type = "Player"
        },
        {
            name = "arrestee",
            description = "The player being arrested.",
            type = "Player"
        }
    },
    returns = {
        {
            name = "canArrest",
            description = "A yes or no as to whether the arrester can arrest the arestee.",
            type = "boolean"
        },
        {
            name = "message",
            description = "The message that is shown when they can't arrest the player.",
            type = "string"
        }
    },
    realm = "Server"
}

function SWEP:Deploy()
    self.Switched = true
    return BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)

    if CLIENT then return end

    self:GetOwner():LagCompensation(true)
    local trace = util.QuickTrace(self:GetOwner():EyePos(), self:GetOwner():GetAimVector() * 90, {self:GetOwner()})
    self:GetOwner():LagCompensation(false)

    local ent = trace.Entity
    if IsValid(ent) and ent.onArrestStickUsed then
        ent:onArrestStickUsed(self:GetOwner())
        return
    end

    ent = self:GetOwner():getEyeSightHitEntity(nil, nil, function(p) return p ~= self:GetOwner() and p:IsPlayer() and p:Alive() and p:IsSolid() end)

    local stickRange = self.stickRange * self.stickRange
    if not IsValid(ent) or (self:GetOwner():EyePos():DistToSqr(ent:GetPos()) > stickRange) or not ent:IsPlayer() then
        return
    end

    if ARREST_RESTRICT then
        if self:GetOwner():GetPos():DistToSqr( ent:GetPos() ) > ARREST_RESTRICTDIST*ARREST_RESTRICTDIST then
            --self:GetOwner():SendLua("chat.AddText(ARREST_PREFIXCOLOR, ARREST_PREFIX, Color(255,255,255), '!')")
            self:GetOwner():ChatPrint("Игрок слишком далеко!")
            return
        end
    end

    local canArrest, message = hook.Call("canArrest", DarkRP.hooks, self:GetOwner(), ent)
    if not canArrest then
        if message then DarkRP.notify(self:GetOwner(), 1, 5, message) end
        return
    end

    net.Start('jail_system')
        net.WriteEntity(ent)
    net.Send(self:GetOwner())    

    --[[ent:arrest(nil, self:GetOwner())
    DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", self:GetOwner():Nick()))

    if self:GetOwner().SteamName then
        DarkRP.log(self:GetOwner():Nick() .. " (" .. self:GetOwner():SteamID() .. ") arrested " .. ent:Nick(), Color(0, 255, 255))
    end]]
end

function SWEP:startDarkRPCommand(usrcmd)
    if game.SinglePlayer() and CLIENT then return end
    if self:GetOwner():IsSuperAdmin() and usrcmd:KeyDown(IN_ATTACK2) then
        if not self.Switched and self:GetOwner():HasWeapon("unarrest_stick") then
            usrcmd:SelectWeapon(self:GetOwner():GetWeapon("unarrest_stick"))
        end
    else
        self.Switched = false
    end
end

if CLIENT then
    net.Receive('jail_system', function()
        local ent = net.ReadEntity()

        if ent:isArrested() then return end

        local frame = vgui.Create('DFrame')
        frame:SetSize(250,150)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle('')
        frame:ShowCloseButton(false)
        frame.Paint = function(self,w,h)
            draw.RoundedBox(4, 0, 0, w, h, Color(0,0,0,150))
            draw.RoundedBox(4, 0, 0, w, 30, Color(255,255,255,230))
            draw.SimpleText( "ВЫБЕРИТЕ ПРИЧИНУ",'Trebuchet24', w/2, 5, Color(0,0,0,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local PReason = vgui.Create( "DComboBox", frame )
        PReason:SetPos( 10, 50 )
        PReason:SetSize( 230, 30 )
        local res = table.GetKeys(ARREST_REASONS)
        PReason:SetValue( res[1] )
        frame.reason = res[1]

        PReason.OnSelect = function( _, _, value )
            frame.reason = value
        end

        PReason.Paint = function(self,w,h)
            draw.RoundedBox(4, 0, 0, w, h, Color(255,255,255,200))
        end


        for k, v in pairs( ARREST_REASONS ) do
            PReason:AddChoice( k )
        end

        local JButton = vgui.Create('DPanel', frame)
        JButton:SetSize(115, 40)
        JButton:SetPos(5, frame:GetTall()-45)
        JButton.OnMousePressed = function() net.Start('jail_system') net.WriteString(frame.reason) net.WriteEntity(ent) net.SendToServer() frame:Remove() end
        JButton.Paint = function(self,w,h)
            if self:IsHovered() then
                draw.RoundedBox(3, 0,0,w,h,Color(0,0,255,255))
                self:SetCursor('hand')
            else
                draw.RoundedBox(3, 0,0,w,h,Color(0,0,255,200))
            end
            draw.SimpleText( "АРЕСТОВАТЬ!",'Trebuchet24', w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local CButton = vgui.Create('DPanel', frame)
        CButton:SetSize(115, 40)
        CButton:SetPos(frame:GetWide()-120, frame:GetTall()-45)
        CButton.OnMousePressed = function() frame:Remove() end
        CButton.Paint = function(self,w,h)
            if self:IsHovered() then
                draw.RoundedBox(3, 0,0,w,h,Color(255,0,0,255))
                self:SetCursor('hand')
            else
                draw.RoundedBox(3, 0,0,w,h,Color(255,0,0,200))
            end
            draw.SimpleText( "ОТМЕНА",'Trebuchet24', w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)

    net.Receive('jail_msg', function()
        local ent = net.ReadEntity()
        local pl = net.ReadEntity()
        local reason = net.ReadString()
        local price = net.ReadInt(32)

        chat.AddText(ARREST_PREFIXCOLOR, ARREST_PREFIX.." ", ARREST_NICKCOLOR, ent:Nick(), ARREST_TEXTCOLOR, ARREST_TEXT1, ARREST_NICKCOLOR, pl:Nick(), ARREST_TEXTCOLOR, " за ", ARREST_REASONCOLOR, reason, ARREST_TEXTCOLOR, ARREST_TEXT2, ARREST_BAILCOLOR, tostring(price)..ARREST_MONEYPREFIX, ARREST_TEXTCOLOR )
    end)
end

if SERVER then
    net.Receive('jail_system', function(ln, pl)
        local reason = net.ReadString()
        local ent = net.ReadEntity()
        local isValidRes = false
        local price = 0

        if ent:isArrested() then return end

        for res, bail in pairs(ARREST_REASONS)do
            if res == reason then isValidRes = true price = bail break end
        end

        if !isValidRes then return end
      
        ent:arrest(nil, pl)
        ent:setBailPrice(price)
        ent:setJailReason(reason)

        if !table.HasValue(ARREST_BAILLIST, ent) then
            table.insert(ARREST_BAILLIST, ent)
        end
        net.Start('send_table')
            net.WriteTable(ARREST_BAILLIST)
        net.Broadcast()

        DarkRP.notify(ent, 0, 20, DarkRP.getPhrase("youre_arrested_by", pl:Nick()))

        net.Start('jail_msg')
            net.WriteEntity(ent)
            net.WriteEntity(pl)
            net.WriteString(reason)
            net.WriteInt(price,32)
        net.Broadcast()

        if pl.SteamName then
            DarkRP.log(pl:Nick() .. " (" .. pl:SteamID() .. ") арестовал " .. ent:Nick(), Color(0, 255, 255))
        end       
    end)

    hook.Add('playerUnArrested', 'remove_from_table', function(pl, police)
        if table.HasValue(ARREST_BAILLIST, pl) then
            table.RemoveByValue(ARREST_BAILLIST, pl) 
            pl:setBailPrice(nil)
            pl:setJailReason("nil")
            net.Start('send_table')
                net.WriteTable(ARREST_BAILLIST)
            net.Broadcast()        
        end
    end)

    hook.Add('PlayerDisconnected', 'remove_from_table2', function(pl)
        if table.HasValue(ARREST_BAILLIST, pl) then
            table.RemoveByValue(ARREST_BAILLIST, pl) 
        end
        net.Start('send_table')
            net.WriteTable(ARREST_BAILLIST)
        net.Broadcast()
    end)
end