if ( SERVER ) then

AddCSLuaFile( "shared.lua" )

SWEP.HoldType = "pistol"
SWEP.DrawCrosshair		= false
-- self:AdjustView(300)


end

if ( CLIENT ) then

SWEP.PrintName = "Glock18c"
SWEP.Author = "Armageddon"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconLetter = "a"

killicon.AddFont( "weapon_elite", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

-- function SWEP:Initialize()
-- if SERVER then
	-- self.Owner:AdjustView( 300 )
-- end
-- end

SWEP.Base = "pb_base"
SWEP.Category                   = "Other"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel 	= "models/weapons/v_pist_glock18.mdl"
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"

SWEP.Weight = 0
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Primary.Sound 		= Sound("Weapon_Glock.Single")
SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 12
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.015
SWEP.Primary.ClipSize = 20
SWEP.Primary.Delay = 0.1
SWEP.Primary.DefaultClip = 99999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pistol"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"