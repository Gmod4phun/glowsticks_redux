AddCSLuaFile()

ENT.Type			= "anim"  
ENT.Base			= "base_gmodentity"  
ENT.PrintName		= "Glowstick (Dropped)"
ENT.Author			= "Patrick Hunt, Gmod4phun"
ENT.Information		= ""
ENT.Category		= "Glowsticks Redux"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

function ENT:Initialize()
	if SERVER then
		self:SetModel("models/gmod4phun/glowsticks/w_glowstick_redux.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetBuoyancyRatio(3.5)
		end
		local time = GetConVar("glowsticks_redux_lifetime"):GetFloat()
		if time > 0 then
			SafeRemoveEntityDelayed(self, time)
		end
	end
end

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
    local ent = ents.Create("ent_glowstick_redux")
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
    ent:Spawn()
    ent:Activate()
	ent:SetColor(ColorRand())
    return ent
end

function ENT:OnTakeDamage(dmg)
	self:Remove()
end

function ENT:PhysicsCollide( data, phys )
	if !self.nextCollideSound or self.nextCollideSound < CurTime() then
		if data.Speed < 350 and data.Speed > 50 then
			self:EmitSound("Default.ImpactSoft")
		elseif data.Speed >= 350 then
			self:EmitSound("Default.ImpactHard")
		end
		self.nextCollideSound = CurTime() + 0.2
	end
end

function ENT:Use(ply)
	if ply:IsPlayer() and ply:HasWeapon("weapon_glowstick_redux") then
		ply:GiveAmmo( 1, "glowsticks" )
	else
		ply:Give("weapon_glowstick_redux")
	end
	self:Remove()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if CLIENT then
		local rgba = self:GetColor();
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			dlight.Pos = self:GetPos()
			dlight.r = rgba.r
			dlight.g = rgba.g
			dlight.b = rgba.b
			dlight.Brightness = 0
			dlight.Size = 256
			dlight.Decay = 0
			dlight.DieTime = CurTime() + 0.05
		end
	end
end
