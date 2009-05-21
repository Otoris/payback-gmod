

local AnimTranslateTable = {}
AnimTranslateTable[ PLAYER_RELOAD ] 	= ACT_HL2MP_GESTURE_RELOAD
AnimTranslateTable[ PLAYER_JUMP ] 		= ACT_HL2MP_JUMP
AnimTranslateTable[ PLAYER_ATTACK1 ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK

/*---------------------------------------------------------
   Name: gamemode:SetPlayerAnimation( )
   Desc: Sets a player's animation
---------------------------------------------------------*/
function GM:SetPlayerAnimation( pl, anim )

	local act = ACT_HL2MP_IDLE
	local Speed = pl:GetVelocity():Length()
	local OnGround = pl:OnGround()
	
	// If it's in the translate table then just straight translate it
	if ( AnimTranslateTable[ anim ] != nil ) then
	
		act = AnimTranslateTable[ anim ]
		
	else
	
		// Crawling on the ground
		if ( OnGround && pl:Crouching() ) then
		
			act = ACT_HL2MP_IDLE_CROUCH
		
			if ( Speed > 0 ) then
				act = ACT_HL2MP_WALK_CROUCH
			end
			
		elseif (Speed > 210) then
		
			act = ACT_HL2MP_RUN
			
		// Player is running on ground
		elseif (Speed > 0) then
		
			act = ACT_HL2MP_WALK
			
		end
	
	end
	
	// Attacking/Reloading is handled by the RestartGesture function
	if ( act == ACT_HL2MP_GESTURE_RANGE_ATTACK || 
		 act == ACT_HL2MP_GESTURE_RELOAD ) then

		pl:RestartGesture( pl:Weapon_TranslateActivity( act ) )
		
		// If this was an attack send the anim to the weapon model
		if (act == ACT_HL2MP_GESTURE_RANGE_ATTACK) then
		
			pl:Weapon_SetActivity( pl:Weapon_TranslateActivity( ACT_RANGE_ATTACK1 ), 0 );
			
		end
		
	return end
	
	// Always play the jump anim if we're in the air
	if ( !OnGround ) then
		
		act = ACT_HL2MP_JUMP
	
	end
	
	// Ask the weapon to translate the animation and get the sequence
	// ( ACT_HL2MP_JUMP becomes ACT_HL2MP_JUMP_AR2 for example)
	local seq = pl:SelectWeightedSequence( pl:Weapon_TranslateActivity( act ) )
	
	// If we're in a vehicle just sit down
	// We should let the vehicle decide this when we have scripted vehicles
	if (pl:InVehicle()) then

		// TODO! Different ACTS for different vehicles!
		local pVehicle = pl:GetVehicle()
		
		if ( pVehicle.HandleAnimation != nil ) then
		
			seq = pVehicle:HandleAnimation( pl )
			if ( seq == nil ) then return end
			
		else
		
			local class = pVehicle:GetClass()
			
			//
			// To realise why you don't need to add to this list,
			// See how the chair handles this ( HandleAnimation )
			//
			if ( class == "prop_vehicle_jeep" ) then
				seq = pl:LookupSequence( "drive_jeep" )
			elseif ( class == "prop_vehicle_airboat" ) then
				seq = pl:LookupSequence( "drive_airboat" )
			else 
				seq = pl:LookupSequence( "drive_pd" )
			end
		
		end
	
	end
	

	
	// If the weapon didn't return a translated sequence just set 
	//	the activity directly.
	if (seq == -1) then 
	
		// Hack.. If we don't have a weapon and we're jumping we
		// use the SLAM animation (prevents the reference anim from showing)
		if (act == ACT_HL2MP_JUMP) then
	
			act = ACT_HL2MP_JUMP_SLAM
		
		end
	
		seq = pl:SelectWeightedSequence( act ) 
		
	end
	
	// Don't keep switching sequences if we're already playing the one we want.
	if (pl:GetSequence() == seq) then return end
	
	// Set and reset the sequence
	pl:SetPlaybackRate( 1.0 )
	pl:ResetSequence( seq )
	pl:SetCycle( 0 )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	
	// Allow noclip if we're in single player
	if ( SinglePlayer() ) then return true end
	
	// Don't if it's not.
	return false
	
end


/*---------------------------------------------------------
   Name: gamemode:OnPhysgunFreeze( weapon, phys, ent, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	
	// Object is already frozen (!?)
	if ( !phys:IsMoveable() ) then return false end
	if ( ent:GetUnFreezable() ) then return false end
	
	phys:EnableMotion( false )
	
	// With the jeep we need to pause all of its physics objects
	// to stop it spazzing out and killing the server.
	if (ent:GetClass() == "prop_vehicle_jeep") then
	
		local objects = ent:GetPhysicsObjectCount()
		
		for i=0, objects-1 do
		
			local physobject = ent:GetPhysicsObjectNum( i )
			physobject:EnableMotion( false )
			
		end
	
	end
	
	// Add it to the player's frozen props
	ply:AddFrozenPhysicsObject( ent, phys )
	
	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:OnPhysgunReload( weapon, player )
   Desc: The physgun wants to freeze a prop
---------------------------------------------------------*/
function GM:OnPhysgunReload( weapon, ply )

	ply:PhysgunUnfreeze( weapon )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerCanPickupWeapon( )
   Desc: Called when a player tries to pickup a weapon.
		  return true to allow the pickup.
---------------------------------------------------------*/
function GM:PlayerCanPickupWeapon( player, entity )
	return true
end


/*---------------------------------------------------------
   Name: gamemode:CanPlayerUnfreeze( )
   Desc: Can the player unfreeze this entity & physobject
---------------------------------------------------------*/
function GM:CanPlayerUnfreeze( ply, entity, physobject )
	return true
end



/*---------------------------------------------------------
   Name: gamemode:PlayerDisconnected( )
   Desc: Player has disconnected from the server.
---------------------------------------------------------*/
function GM:PlayerDisconnected( player )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSay( )
   Desc: A player (or server) has used say. Return a string
		 for the player to say. Return an empty string if the
		 player should say nothing.
---------------------------------------------------------*/
function GM:PlayerSay( player, text, teamonly )
	return text
end


/*---------------------------------------------------------
   Name: gamemode:PlayerDeathThink( player )
   Desc: Called when the player is waiting to respawn
---------------------------------------------------------*/
function GM:PlayerDeathThink( pl )

	if (  pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then return end

	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then
	
		pl:Spawn()
		
	end
	
end

/*---------------------------------------------------------
	Name: gamemode:PlayerUse( player, entity )
	Desc: A player has attempted to use a specific entity
		Return true if the player can use it
//--------------------------------------------------------*/
function GM:PlayerUse( pl, entity )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies.
---------------------------------------------------------*/
function GM:PlayerDeath( Victim, Inflictor, Attacker )

	// Don't spawn for at least 2 seconds
	Victim.NextSpawnTime = CurTime() + 2

	// Convert the inflictor to the weapon that they're holding if we can.
	// This can be right or wrong with NPCs since combine can be holding a 
	// pistol but kill you by hitting you with their arm.
	if ( Inflictor && Inflictor == Attacker && (Inflictor:IsPlayer() || Inflictor:IsNPC()) ) then
	
		Inflictor = Inflictor:GetActiveWeapon()
		if ( !Inflictor || Inflictor == NULL ) then Inflictor = Attacker end
	
	end
	
	Attacker:AddFrags( 1 )
	
	if (Attacker == Victim) then
	
		umsg.Start( "PlayerKilledSelf" )
			umsg.Entity( Victim )
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " suicided!\n" )
		
	return end

	if ( Attacker:IsPlayer() ) then
	
		umsg.Start( "PlayerKilledByPlayer" )
		
			umsg.Entity( Victim )
			umsg.String( Inflictor:GetClass() )
			umsg.Entity( Attacker )
		
		umsg.End()
		
		MsgAll( Attacker:Nick() .. " killed " .. Victim:Nick() .. " using " .. Inflictor:GetClass() .. "\n" )
		
	return end
	
	umsg.Start( "PlayerKilled" )
	
		umsg.Entity( Victim )
		umsg.String( Inflictor:GetClass() )
		umsg.String( Attacker:GetClass() )

	umsg.End()
	
	MsgAll( Victim:Nick() .. " was killed by " .. Attacker:GetClass() .. "\n" )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerInitialSpawn( )
   Desc: Called just before the player's first spawn
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( pl )

	if not pl.Follower then
		local ent = ents.Create( "info_followplayer" )
		ent:SetPos( pl:GetPos() + Vector( 0,0,10 ) )
		ent:Spawn()
		ent:SetParent( pl )
		pl.Follower = ent
	end
	
	pl:SetViewEntity( pl.Follower )
	pl:SetJumpPower( 500 )

	pl:SetTeam( TEAM_UNASSIGNED )
	pl:SetNWString( "MEPOINTS", "00000000" )
	pl:ConCommand( "pb_playermenu" )
	if ( self.TeamBased ) then
		pl:ConCommand( "gm_showteam" )
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawnAsSpectator( )
   Desc: Player spawns as a spectator
---------------------------------------------------------*/
function GM:PlayerSpawnAsSpectator( pl )

	pl:SetTeam( TEAM_SPECTATOR )
	pl:Spectate( OBS_MODE_ROAMING )

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
---------------------------------------------------------*/
function GM:PlayerSpawn( pl )

	//
	// If the player doesn't have a team in a TeamBased game
	// then spawn him as a spectator
	//
	if ( self.TeamBased && ( pl:Team() == TEAM_SPECTATOR || pl:Team() == TEAM_UNASSIGNED ) ) then

		self:PlayerSpawnAsSpectator( pl )
		return
	
	end

	// Stop observer mode
	pl:UnSpectate()

	// Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	// Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSetModel( )
   Desc: Set the player's model
---------------------------------------------------------*/
function GM:PlayerSetModel( pl )

	local cl_playermodel = pl:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	pl:SetModel( modelname )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLoadout( )
   Desc: Give the player the default spawning weapons/ammo
---------------------------------------------------------*/
local randomweapons = {}

randomweapons[1] = "weapon_glock18c"
randomweapons[2] = "weapon_ak_47"
randomweapons[3] = "weapon_Benelli_M3_Super_90"
	

function GM:PlayerLoadout( pl )
	
	pl:Give( randomweapons[math.random( 1, 3 )] )
	
	// Switch to prefered weapon if they have it
	-- local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )
	
	-- if ( pl:HasWeapon( cl_defaultweapon )  ) then
		-- pl:SelectWeapon( cl_defaultweapon ) 
	-- end
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSelectTeamSpawn( player )
   Desc: Find a spawn point entity for this player's team
---------------------------------------------------------*/
function GM:PlayerSelectTeamSpawn( TeamID, pl )

	local SpawnPointEntity = team.GetSpawnPoint( TeamID )
	if ( !SpawnPointEntity ) then return end
	
	local SpawnPoints = ents.FindByClass( SpawnPointEntity )
	local Count = table.Count( SpawnPoints )
	
	if ( Count == 0 ) then return end
	
	return SpawnPoints[ math.random( 1, Count ) ]

end

/*---------------------------------------------------------
   Name: gamemode:PlayerSelectSpawn( player )
   Desc: Find a spawn point entity for this player
---------------------------------------------------------*/
function GM:PlayerSelectSpawn( pl )

	if ( self.TeamBased ) then
	
		local ent = self:PlayerSelectTeamSpawn( pl:Team(), pl )
		if ( IsValid(ent) ) then return ent end
	
	end

	// Save information about all of the spawn points
	// in a team based game you'd split up the spawns
	if (self.SpawnPoints == nil) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		// CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		// DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		// (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		// TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )		
		
		// If any of the spawnpoints have a MASTER flag then only use that one.
		for k, v in pairs( self.SpawnPoints ) do
		
			if ( v:HasSpawnFlags( 1 ) ) then
			
				self.SpawnPoints = {}
				self.SpawnPoints[1] = v
			
			end
		
		end

	end
	
	local Count = table.Count( self.SpawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil 
	end
	
	local ChosenSpawnPoint = nil
	
	// Try to work out the best, random spawnpoint (in 6 goes)
	for i=0, 6 do
	
		ChosenSpawnPoint = self.SpawnPoints[ math.random( 1, Count ) ]
		
		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			
			// Todo.. don't spawn inside stuff or really near other players.
			
			self.LastSpawnPoint = ChosenSpawnPoint
			pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
			return ChosenSpawnPoint
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

/*---------------------------------------------------------
   Name: gamemode:WeaponEquip( weapon )
   Desc: Player just picked up (or was given) weapon
---------------------------------------------------------*/
function GM:WeaponEquip( weapon )
end

/*---------------------------------------------------------
   Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
   Desc: Scale the damage based on being shot in a hitbox
		 Return true to not take damage
---------------------------------------------------------*/
function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )

	// More damage if we're shot in the head
	 if ( hitgroup == HITGROUP_HEAD ) then
	 
		dmginfo:ScaleDamage( 0.25 )
	 
	 end
	 
	// Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM || 
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_GEAR ) then
	 
		dmginfo:ScaleDamage( 0.25 )
	 
	 end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerDeathSound()
   Desc: Return true to not play the default sounds
---------------------------------------------------------*/
function GM:PlayerDeathSound()
	return true
end

/*---------------------------------------------------------
   Name: gamemode:SetupPlayerVisibility()
   Desc: Add extra positions to the player's PVS
---------------------------------------------------------*/
function GM:SetupPlayerVisibility( pPlayer, pViewEntity )
	//AddOriginToPVS( vector_position_here )
end

/*---------------------------------------------------------
   Name: gamemode:OnDamagedByExplosion( ply, dmginfo)
   Desc: Player has been hurt by an explosion
---------------------------------------------------------*/
function GM:OnDamagedByExplosion( ply, dmginfo )
	ply:SetDSP( 35, false )
end

/*---------------------------------------------------------
   Name: gamemode:CanPlayerSuicide( ply )
   Desc: Player typed KILL in the console. Can they kill themselves?
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )
	return true 
end

/*---------------------------------------------------------
   Name: gamemode:PlayerLeaveVehicle()
---------------------------------------------------------*/
function GM:PlayerLeaveVehicle( ply, veichle )
end

/*---------------------------------------------------------
   Name: gamemode:CanExitVehicle()
			If the player is allowed to leave the vehicle, return true
---------------------------------------------------------*/
function GM:CanExitVehicle( veichle, passenger )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSwitchFlashlight()
		Return true to allow action
---------------------------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	return false
end

/*---------------------------------------------------------
   Name: gamemode:PlayerCanJoinTeam( ply, teamid )
		Allow mods/addons to easily determine whether a player 
			can join a team or not
---------------------------------------------------------*/
function GM:PlayerCanJoinTeam( ply, teamid )
	
	local TimeBetweenSwitches = 5
	if ( ply.LastTeamSwitch && RealTime()-ply.LastTeamSwitch < TimeBetweenSwitches ) then
		ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", TimeBetweenSwitches - (RealTime()-ply.LastTeamSwitch) ) )
		return false
	end
	
	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerRequestTeam()
		Player wants to change team
---------------------------------------------------------*/
function GM:PlayerRequestTeam( ply, teamid )
	
	// No changing teams if not teambased!
	if ( !self.TeamBased ) then return end
	
	// This team isn't joinable
	if ( !team.Joinable( teamid ) ) then 
		ply:ChatPrint( "You can't join that team" )
	return end
	
	// This team isn't joinable
	if ( !self:PlayerCanJoinTeam( ply, teamid ) ) then 
		// Messages here should be outputted by this function
	return end
	
	// Already on this team!
	if ( ply:Team() == teamid ) then 
		ply:ChatPrint( "You're already on that team" )
	return end
	

	self:PlayerJoinTeam( ply, teamid )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerJoinTeam()
		Make player join this team
---------------------------------------------------------*/
function GM:PlayerJoinTeam( ply, teamid )
	
	local iOldTeam = ply:Team()
	
	if ( ply:Alive() ) then
		if (iOldTeam == TEAM_SPECTATOR) then
			ply:KillSilent()
		else
			ply:Kill()
		end
	end

	ply:SetTeam( teamid )
	ply.LastTeamSwitch = RealTime()
	
	self:OnPlayerChangedTeam( ply, iOldTeam, teamid )
	
end

/*---------------------------------------------------------
   Name: gamemode:OnPlayerChangedTeam( ply, oldteam, newteam )
---------------------------------------------------------*/
function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

	// Here's an immediate respawn thing by default. If you want to 
	// re-create something more like CS or some shit you could probably
	// change to a spectator or something while dead.
	if ( newteam == TEAM_SPECTATOR ) then
	
		// If we changed to spectator mode, respawn where we are
		local Pos = ply:EyePos()
		ply:Spawn()
		ply:SetPos( Pos )
		
	elseif ( oldteam == TEAM_SPECTATOR ) then
	
		// If we're changing from spectator, join the game
		ply:Spawn()
	
	else
	
		// If we're straight up changing teams just hang
		//  around until we're ready to respawn onto the 
		//  team that we chose
		
	end
	
	PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerSpray()
		Return true to prevent player spraying
---------------------------------------------------------*/
function GM:PlayerSpray( ply )
	
	return false
	
end

concommand.Add( "changeteam", function( pl, cmd, args ) hook.Call( "PlayerRequestTeam", GAMEMODE, pl, tonumber(args[1]) ) end )
