AddCSLuaFile()

ENT.Type			= "anim"  
ENT.Base			= "base_gmodentity"  
ENT.PrintName		= "Glowstick Glow"
ENT.Author			= "Patrick Hunt, Gmod4phun"
ENT.Information		= "Alright, you got me. It's a fake glow."
ENT.Category		= "Glowsticks Redux"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Glowing" )

	if SERVER then
		self:SetGlowing( false )
	end
end

function ENT:Initialize()   
	if SERVER then
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		self:DrawShadow(false)
	end
end

function ENT:Draw()
end

function ENT:Think()
	if CLIENT then
		if self:GetGlowing() then
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
end
