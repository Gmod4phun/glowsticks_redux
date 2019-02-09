AddCSLuaFile()

if SERVER then
	CreateConVar( "glowsticks_redux_lifetime", 0, FCVAR_NOTIFY, "Sets the lifetime of a Glowstick in seconds")
end

sound.Add(
{
    name = "Glowstick.Shake",
    channel = CHAN_USER_BASE+1,
    volume = 0.2,
	pitch = { 95, 110 },
    soundlevel = SNDLVL_IDLE,
    sound = "gmod4phun/glowsticks/glowstick_shake.wav"
})
sound.Add(
{
    name = "Glowstick.Snap",
    channel = CHAN_USER_BASE+1,
    volume = 0.7,
	pitch = { 95, 110 },
    soundlevel = SNDLVL_IDLE,
    sound = "gmod4phun/glowsticks/glowstick_snap.wav"
})
	
game.AddAmmoType( {
	name = "glowsticks",
	dmgtype = DMG_CRUSH,
	tracer = TRACER_NONE,
	plydmg = 0,
	npcdmg = 0,
	force = 0,
	maxcarry = 5
} )

cleanup.Register( "glowsticks" )

if CLIENT then	
	matproxy.Add({
		name = "GlowstickReduxColor",
		init = function(self, mat, values) end,
		bind = function(self, mat, ent)
			if IsValid(ent) then
				if ent.GetGlowstickReduxColor then
					mat:SetVector("$color2", ent:GetGlowstickReduxColor())
				else
					mat:SetVector("$color2", Vector(1,1,1))
				end
			end
		end
	})
	
	// menu options
	CreateClientConVar("glowsticks_redux_color_r", 255, true, true)
	CreateClientConVar("glowsticks_redux_color_g", 255, true, true)
	CreateClientConVar("glowsticks_redux_color_b", 255, true, true)
	
	local function GLOWSTICKS_REDUX_MENU_PANEL(panel)
		panel:ClearControls()
		
		panel:AddControl("Label", {Text = "\nGlowsticks settings"})
		panel:AddControl( "Color", { Label = "Glowstick Color", Red = "glowsticks_redux_color_r", Green = "glowsticks_redux_color_g", Blue = "glowsticks_redux_color_b"} )
	end
	
	hook.Add("PopulateToolMenu", "GLOWSTICKS_REDUX_PopulateToolMenu", function()
		spawnmenu.AddToolMenuOption("Utilities", "Gmod4phun", "GLOWSTICKS_REDUX_MENU", "Glowsticks Redux", "", "", GLOWSTICKS_REDUX_MENU_PANEL)
	end)
end
