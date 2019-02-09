if CLIENT then
	language.Add ("ent_glowstick_redux", "Glowstick")
	language.Add ("glowsticks_ammo", "Glowsticks")
	language.Add ("cleanup_glowsticks", "Glowsticks")
	language.Add ("cleaned_glowsticks", "Glowsticks are gone!")
	
	SWEP.Slot			= 1; 
	SWEP.SlotPos		= 1; 
	SWEP.WepSelectIcon	= surface.GetTextureID( "vgui/entities/inventory_glowstick_redux" )
  	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 75
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
end

SWEP.Weight			= 5
SWEP.AutoSwitchTo	= false
SWEP.AutoSwitchFrom	= false

SWEP.PrintName			= "Glowstick"
SWEP.Author				= "Patrick Hunt, Gmod4phun"
SWEP.Contact				= ""
SWEP.Purpose				= "See in the dark, duh"
SWEP.Instructions			= "Primary to drop a glowstick, secondary to throw it"
SWEP.HoldType				= "melee"
SWEP.Category				= "Glowsticks Redux"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/gmod4phun/glowsticks/c_glowstick_redux.mdl"
SWEP.WorldModel				= "models/gmod4phun/glowsticks/w_glowstick_redux.mdl"
SWEP.UseHands				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "glowsticks"
SWEP.Primary.Delay			= 3.5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 3.5

local meta = FindMetaTable("Player")
function meta:GetGlowstickReduxColor()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == "weapon_glowstick_redux" then
		return wep:GetGlowstickColor():ToVector()
	else
		return Color(255,255,255):ToVector()
	end
end

function SWEP:DoDrawCrosshair(x, y)
	return true
end

function SWEP:ChangeColorTo(col)
	self:SetColor(col)
	if SERVER and IsValid(self.glowentity) then
		self.glowentity:SetColor(col)
	end
end

function SWEP:GetGlowstickColor()
	local col = self:GetColor()
	return Color(col.r, col.g, col.b)
end

function SWEP:GetPlayerGlowstickColorValues()
	local ply = self.Owner
	if !IsValid(ply) then
		return 255, 255, 255
	else
		local r = ply:GetInfoNum("glowsticks_redux_color_r", 255)
		local g = ply:GetInfoNum("glowsticks_redux_color_g", 255)
		local b = ply:GetInfoNum("glowsticks_redux_color_b", 255)
		return r, g, b
	end
end

function SWEP:UpdateGlowstickColor()
	local ply = self.Owner
	if !IsValid(ply) then self:ChangeColorTo(color_white) end
	local r, g, b = self:GetPlayerGlowstickColorValues()
	self:ChangeColorTo(Color(r,g,b))
end

function SWEP:Think()
	if SERVER then
		local ply = self.Owner
		if IsValid(ply) then
			local r, g, b = self:GetPlayerGlowstickColorValues()
			if !ply.GLOWSTICK_LastColor_R or !ply.GLOWSTICK_LastColor_G or !ply.GLOWSTICK_LastColor_B or ply.GLOWSTICK_LastColor_R != r or ply.GLOWSTICK_LastColor_G != g or ply.GLOWSTICK_LastColor_B != b then
				self:UpdateGlowstickColor()
				ply.GLOWSTICK_LastColor_R = r
				ply.GLOWSTICK_LastColor_G = g
				ply.GLOWSTICK_LastColor_B = b
			end
		end
	end
end

function SWEP:PostDrawViewModel(vm, wep, ply)
	if !vm.GetGlowstickReduxColor then
		vm.GetGlowstickReduxColor = function() return ply:GetGlowstickReduxColor() end
	end
end

function SWEP:SetGlowing(b)
	self:SetSkin(b and 0 or 1)
	if IsValid(self.glowentity) then
		self.glowentity:SetGlowing(b)
	end
	local ply = self.Owner
	if IsValid(ply) then
		local vm = ply:GetViewModel()
		if IsValid(vm) then
			vm:SetSkin(b and 0 or 1)
		end
	end
end

function SWEP:Initialize()
	util.PrecacheSound("glowstick/glowstick_snap.wav");
	util.PrecacheSound("glowstick/glowstick_shake.wav");
	self:SetWeaponHoldType( self.HoldType )
	self:UpdateGlowstickColor()
	self:SetGlowing(false)
end

function SWEP:Deploy()
	self:UpdateGlowstickColor()
	
	self:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire(CurTime() + 2.5)
	self:SetNextSecondaryFire(CurTime() + 2.5)
	if SERVER then
		SafeRemoveEntity(self.glowentity)
		self.glowentity = ents.Create("ent_glowstick_redux_glow")
		self.glowentity:SetOwner(self)
		self.glowentity:SetPos(self:GetPos())
		self.glowentity:SetParent(self)
		self.glowentity:SetColor(self:GetGlowstickColor())
		self.glowentity:Spawn()
		self.glowentity:Activate()
		self:SetGlowing(false)
		
		timer.Simple(0.5, function()
			if IsValid(self) then
				self:SetGlowing(true)
			end
		end)
	end
	return true
end

function SWEP:ThrowGlowstick(power)
	self:SetNextPrimaryFire(CurTime() + 3.5)
	self:SetNextSecondaryFire(CurTime() + 3.5)
	timer.Simple(0.5, function()
		if !IsValid(self) then return end
		self:TakePrimaryAmmo(1)
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		if SERVER then
			self:SetGlowing(false)
			local ent = ents.Create("ent_glowstick_redux")
			ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
			ent:SetAngles(self.Owner:EyeAngles())
			ent:SetColor(self:GetGlowstickColor())
			ent:Spawn()
			ent:Activate()
			self.Owner:AddCleanup("glowsticks", ent)
			
			local phys = ent:GetPhysicsObject()
			phys:SetVelocity(self.Owner:GetAimVector() * (power or 100))
			phys:AddAngleVelocity(Vector(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000)))
		end
	end)
	
	timer.Simple(1, function()
		if SERVER then
			if !IsValid(self) then return end
			if self:Ammo1() < 1 then
				self.Owner:ConCommand("lastinv")
				self:Remove()
				return
			end
			self:SendWeaponAnim(ACT_VM_DRAW)
			timer.Simple(0.5, function()
				if !IsValid(self) then return end
				self:SetGlowing(true)
			end)
		end
	end)
end

function SWEP:PrimaryAttack()
	if ( self:Ammo1() < 1 ) then return end
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	self:ThrowGlowstick(125)
end

function SWEP:SecondaryAttack()
	if ( self:Ammo1() < 1) then return end
	self:SendWeaponAnim( ACT_VM_THROW )
	self:ThrowGlowstick(600)
end

function SWEP:Holster()
	if SERVER then
		SafeRemoveEntity(self.glowentity)
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then
		SafeRemoveEntity(self.glowentity)
	end
end

function SWEP:OnDrop()
	if SERVER then
		local ent = ents.Create("ent_glowstick_redux")
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:EyeAngles())
		ent:SetColor(self:GetGlowstickColor())
		ent:Spawn()
		ent:Activate()
		
		local newphys = ent:GetPhysicsObject()
		local oldphys = self:GetPhysicsObject()
		if IsValid(newphys) and IsValid(oldphys) then
			newphys:SetVelocity(oldphys:GetVelocity())
		end
		
		if IsValid(self.currentGlowstickOwner) then
			self.currentGlowstickOwner:RemoveAmmo(1, self.Primary.Ammo)
		end
		SafeRemoveEntity(self)
	end
end

function SWEP:Equip(owner)
	if SERVER then
		self.currentGlowstickOwner = owner
		SafeRemoveEntity(self.glowentity)
	end
end

function SWEP:Reload()
	return true
end
