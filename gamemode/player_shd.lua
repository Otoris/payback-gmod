

/*---------------------------------------------------------
   Name: gamemode:UpdateAnimation( )
   Desc: Animation updates (pose params etc) should be done here
---------------------------------------------------------*/
function GM:UpdateAnimation( pl )

	if ( pl:InVehicle() ) then

		local Vehicle =  pl:GetVehicle()
	
		// We only need to do this clientside..
		if ( CLIENT ) then
		
			//
			// This is used for the 'rollercoaster' arms
			//
			local Velocity = Vehicle:GetVelocity()
			pl:SetPoseParameter( "vertical_velocity", Velocity.z * 0.01 ) 

			// Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 // convert from 0..1 to -1..1
			pl:SetPoseParameter( "vehicle_steer", steer  ) 
			
		end
	
	end

end

/*---------------------------------------------------------
   Name: gamemode:PlayerTraceAttack( )
   Desc: A bullet has been fired and hit this player
		 Return true to completely override internals
---------------------------------------------------------*/
function GM:PlayerTraceAttack( ply, dmginfo, dir, trace )

	if ( SERVER ) then
		GAMEMODE:ScalePlayerDamage( ply, trace.HitGroup, dmginfo )
	end

	return false
end


/*---------------------------------------------------------
   Name: gamemode:SetPlayerSpeed( )
   Desc: Sets the player's run/walk speed
---------------------------------------------------------*/
function GM:SetPlayerSpeed( ply, walk, run )

	ply:SetWalkSpeed( walk )
	ply:SetRunSpeed( run )
	
end



/*---------------------------------------------------------
   Name: gamemode:CanPlayerEnterVehicle( player, vehicle, role )
   Desc: Return true if player can enter vehicle
---------------------------------------------------------*/
function GM:CanPlayerEnterVehicle( player, vehicle, role )
	return true
end

/*---------------------------------------------------------
   Name: gamemode:PlayerEnteredVehicle( player, vehicle, role )
   Desc: Player entered the vehicle fine
---------------------------------------------------------*/
function GM:PlayerEnteredVehicle( player, vehicle, role )
end


/*---------------------------------------------------------
   Name: gamemode:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )
   Desc: Called when a player steps
		pFilter is the recipient filter to use for effects/sounds 
			and is only valid SERVERSIDE. Clientside needs no filter!
		Return true to not play normal sound
---------------------------------------------------------*/
function GM:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )
	
	
	/*
	// Draw effect on footdown
	local effectdata = EffectData()
		effectdata:SetOrigin( vPos )
	util.Effect( "phys_unfreeze", effectdata, true, pFilter )
	*/
	
	/*
	// Don't play left foot
	if ( iFoot == 0 ) then return true end
	*/
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerStepSoundTime( ply, iType, bWalking )
   Desc: Return the time between footsteps
---------------------------------------------------------*/
function GM:PlayerStepSoundTime( ply, iType, bWalking )
	
	local fStepTime = 350
	local fMaxSpeed = ply:GetMaxSpeed()
	
	if ( iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT ) then
		
		if ( fMaxSpeed <= 100 ) then 
			fStepTime = 400
		elseif ( fMaxSpeed <= 300 ) then 
			fStepTime = 350
		else 
			fStepTime = 250 
		end
	
	elseif ( iType == STEPSOUNDTIME_ON_LADDER ) then
	
		fStepTime = 450 
	
	elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then
	
		fStepTime = 600 
	
	end
	
	// Step slower if crouching
	if ( ply:Crouching() ) then
		fStepTime = fStepTime + 50
	end
	
	return fStepTime
	
end
