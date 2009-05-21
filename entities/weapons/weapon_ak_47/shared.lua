if ( SERVER ) then

AddCSLuaFile( "shared.lua" )

SWEP.HoldType = "ar2"

end

if ( CLIENT ) then

SWEP.PrintName = "AK-47"
SWEP.Author = "Armageddon"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.IconLetter = "a"

killicon.AddFont( "weapon_elite", "CSKillIcons", SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

end

SWEP.Base = "pb_base"
SWEP.Category                   = "Other"

SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.ViewModel 	= "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"

SWEP.Weight = 0
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Primary.Sound          = Sound("Weapon_AK47.Single")

SWEP.Primary.Recoil = 0
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.03
SWEP.Primary.ClipSize = 30
SWEP.Primary.Delay = 0.1
SWEP.Primary.DefaultClip = 99999
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "smg1"
--SWEP.Primary.anim = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2 

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"