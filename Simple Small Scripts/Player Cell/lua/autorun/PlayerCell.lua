local ENT = {}
ENT.Base = "base_gmodentity" 
ENT.Type = "anim"
ENT.PrintName = "Player Cell"
ENT.Category = "NikWorks"
ENT.Author = "NikSton"
ENT.Spawnable = true
ENT.AdminSpawnable = true 

function ENT:Initialize()
     self:SetModel("models/cellbox/cellbox_player.mdl")
     if CLIENT then return end
     self:PhysicsInit(SOLID_VPHYSICS)
     self:SetMoveType(MOVETYPE_VPHYSICS)
     self:SetSolid(SOLID_VPHYSICS)
     self:SetUseType(SIMPLE_USE)
end

function ENT:Jail(ply)
    self.jailed = ply
    ply:Freeze(true)
    ply:SetVelocity(Vector(0, 0, 0))
    ply:SetEyeAngles(Angle(0, 0, 0))
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetPos(self:GetPos() + self:GetAngles():Up() * 3)
    ply:SetParent(self)
end

function ENT:UnJail()
    if IsValid(self.jailed) then
        local ply = self.jailed
        ply:SetParent()
        ply:SetMoveType(MOVETYPE_WALK)
        ply:Freeze(false)
        self:Remove()
    end
end

function ENT:Touch(ply)
if !ply:IsPlayer() or IsValid(self.jailed) then return end
    self:Jail(ply)
end

ENT.OnRemove = ENT.UnJail

function ENT:Use(ply)
    self:UnJail(true)
end

function ENT:Draw()
	self:DrawModel()
end
scripted_ents.Register(ENT, "ent_cell")