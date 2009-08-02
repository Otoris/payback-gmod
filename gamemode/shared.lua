
/*---------------------------------------------------------

  This file should contain variables and functions that are 
   the same on both client and server.

  This file will get sent to the client - so don't add 
   anything to this file that you don't want them to be
   able to see.

---------------------------------------------------------*/

include( 'obj_player_extend.lua' )

include( 'gravitygun.lua' )
include( 'player_shd.lua' )

GM.Name 		= "Payback"
GM.Author 		= "Otoris & Armageddon"
GM.Email 		= "otoris@altusfilms.com"
GM.Website 		= ""
GM.TeamBased 	= false

--Simple Tables

mdlList = {}

mdlList[1] = "models/player/Group01/Female_02.mdl"
mdlList[2] = "models/player/Group01/Female_03.mdl"
mdlList[3] = "models/player/Group01/Male_01.mdl"
mdlList[4] = "models/player/Group01/male_07.mdl"
	


nameList = {

	"Jean",
	"Lisa",
	"Mike",
	"Jack"
		
}

KEVLAR = {
	
	"Kevlar 20",
	"Kevlar 32",
	"Kevlar 19",
	"Kevlar 23"

}
	

ST = {

	"Strength 80",
	"Strength 75",
	"Strength 92",
	"Strength 83"
}

SP = {

	"Speed 75",
	"Speed 83",
	"Speed 24",
	"Speed 25"

}

E = {

	"Stamina 90",
	"Stamina 76",
	"Stamina 72",
	"Stamina 83"
	
}

Eyes = {

	"Dark Green Eyes",
	"Steele Eyes",
	"Black Eyes",
	"Dark Blue Eyes"
	
}

Weight = {

	"Weight 128",
	"Weight 132",
	"Weight 175",
	"Weight 180"

}

HColor = {

	"Light Brown Hair",
	"Dark Brown Hair",
	"Black Hair",
	"Black Hair"

}

FSize = {

	"Foot Size 7",
	"Foot Size 16",
	"Foot Size 12",
	"Foot Size 11"

}
/*---------------------------------------------------------
   Name: gamemode:PlayerHurt( )
   Desc: Called when a player is hurt.
---------------------------------------------------------*/
function GM:PlayerHurt( player, attacker, healthleft, healthtaken )
end


/*---------------------------------------------------------
   Name: gamemode:KeyPress( )
   Desc: Player pressed a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyPress( player, key )
end


/*---------------------------------------------------------
   Name: gamemode:KeyRelease( )
   Desc: Player released a key (see IN enums)
---------------------------------------------------------*/
function GM:KeyRelease( player, key )
end


/*---------------------------------------------------------
   Name: gamemode:PlayerConnect( )
   Desc: Player has connects to the server (hasn't spawned)
---------------------------------------------------------*/
function GM:PlayerConnect( name, address )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerAuthed( )
   Desc: Player's STEAMID has been authed
---------------------------------------------------------*/
function GM:PlayerAuthed( ply, SteamID, UniqueID )
end



/*---------------------------------------------------------
   Name: gamemode:PropBreak( )
   Desc: Prop has been broken
---------------------------------------------------------*/
function GM:PropBreak( attacker, prop )
end


/*---------------------------------------------------------
   Name: gamemode:PhysgunPickup( )
   Desc: Return true if player can pickup entity
---------------------------------------------------------*/
function GM:PhysgunPickup( ply, ent )

	// Don't pick up players
	if ( ent:GetClass() == "player" ) then return false end

	return true
end


/*---------------------------------------------------------
   Name: gamemode:PhysgunDrop( )
   Desc: Dropped an entity
---------------------------------------------------------*/
function GM:PhysgunDrop( ply, ent )
end


/*---------------------------------------------------------
   Name: gamemode:SetupMove( player, movedata )
   Desc: Allows us to change stuff before the engine 
		  processes the movements
---------------------------------------------------------*/
function GM:SetupMove( ply, move )
end


/*---------------------------------------------------------
   Name: gamemode:FinishMove( player, movedata )
---------------------------------------------------------*/
function GM:FinishMove( ply, move )

end

/*---------------------------------------------------------
   Name: gamemode:Move
   This basically overrides the NOCLIP, PLAYERMOVE movement stuff.
   It's what actually performs the move. 
   Return true to not perform any default movement actions. (completely override)
---------------------------------------------------------*/
function GM:Move( ply, mv )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
---------------------------------------------------------*/
function GM:PlayerShouldTakeDamage( ply, attacker )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:ContextScreenClick(  aimvec, mousecode, pressed, ply )
   'pressed' is true when the button has been pressed, false when it's released
---------------------------------------------------------*/
function GM:ContextScreenClick( aimvec, mousecode, pressed, ply )
	
	// We don't want to do anything by default, just feed it to the weapon
	local wep = ply:GetActiveWeapon()
	if ( ValidEntity( wep ) && wep.ContextScreenClick ) then
		wep:ContextScreenClick( aimvec, mousecode, pressed, ply )
	end
	
end

/*---------------------------------------------------------
   Name: Text to show in the server browser
---------------------------------------------------------*/
function GM:GetGameDescription()
	return self.Name
end


/*---------------------------------------------------------
   Name: Saved
---------------------------------------------------------*/
function GM:Saved()
end


/*---------------------------------------------------------
   Name: Restored
---------------------------------------------------------*/
function GM:Restored()
end


/*---------------------------------------------------------
   Name: EntityRemoved
   Desc: Called right before an entity is removed. Note that this
   isn't going to be totally reliable on the client since the client
   only knows about entities that it has had in its PVS.
---------------------------------------------------------*/
function GM:EntityRemoved( ent )
end


/*---------------------------------------------------------
   Name: Tick
   Desc: Like Think except called every tick on both client and server
---------------------------------------------------------*/
function GM:Tick()
end

/*---------------------------------------------------------
   Name: OnEntityCreated
   Desc: Called right after the Entity has been made visible to Lua
---------------------------------------------------------*/
function GM:OnEntityCreated( Ent )
end

/*---------------------------------------------------------
   Name: gamemode:EntityKeyValue( ent, key, value )
   Desc: Called when an entity has a keyvalue set
	      Returning a string it will override the value
---------------------------------------------------------*/
function GM:EntityKeyValue( ent, key, value )
end

/*---------------------------------------------------------
   Name: gamemode:CreateTeams()
   Desc: Note - HAS to be shared.
---------------------------------------------------------*/
function GM:CreateTeams()

	// Don't do this if not teambased. But if it is teambased we
	// create a few teams here as an example. If you're making a teambased
	// gamemode you should override this function in your gamemode
	if ( !self.TeamBased ) then return end
	
	TEAM_BLUE = 1
	team.SetUp( TEAM_BLUE, "Blue Team", Color( 0, 0, 255 ) )
	team.SetSpawnPoint( TEAM_BLUE, "ai_hint" ) // <-- This would be info_terrorist or some entity that is in your map
	
	TEAM_ORANGE = 2
	team.SetUp( TEAM_ORANGE, "Orange Team", Color( 255, 150, 0 ) )
	team.SetSpawnPoint( TEAM_ORANGE, "sky_camera" ) // <-- This would be info_terrorist or some entity that is in your map
	
	TEAM_SEXY = 3
	team.SetUp( TEAM_SEXY, "Sexy Team", Color( 255, 150, 150 ) )
	team.SetSpawnPoint( TEAM_SEXY, "info_player_start" ) // <-- This would be info_terrorist or some entity that is in your map
	
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" ) 

end
