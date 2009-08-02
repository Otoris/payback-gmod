AddCSLuaFile( 'cl_scoreboard.lua' )
AddCSLuaFile( 'cl_weather.lua' )
AddCSLuaFile( 'cl_hudpickup.lua' )
AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'cl_targetid.lua' )
AddCSLuaFile( 'cl_deathnotice.lua' )

include( 'shared.lua' )
include( 'player.lua' )
include( 'npc.lua' )

GM.PlayerSpawnTime = {}

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/

function GM:Initialize( )	
local Weathers = {

	"sunny",
	"cloudy",
	"rain",
	"sunnyrain",
	"storm",
	"dark",
	"darkrain"

}
	

timer.Create( "pbweathertimer", 120, 0, function()
	SetGlobalString( "weather", Weathers[math.random(1, #Weathers)] )
end )

end


/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )	
end


/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function GM:Think( )
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end

/*---------------------------------------------------------
   Name: gamemode:DoPlayerDeath( )
   Desc: Carries out actions when the player dies 		 
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()
	
	ply:AddDeaths( 1 )
	ply:SetNWString( "MEPOINTS", "00000000" )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:SetNWString( "MEPOINTS", tonumber(attacker:GetNWString( "MEPOINTS" ))  + 1500 )
			attacker:AddFrags( 1 )
		end
		
	end
	
end


/*---------------------------------------------------------
   Name: gamemode:EntityTakeDamage( entity, inflictor, attacker, amount, dmginfo )
   Desc: The entity has received damage	 
---------------------------------------------------------*/
function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )

 	if ent:IsPlayer() and dmginfo:IsFallDamage() then 
   
		dmginfo:SetDamage( 0 ) 
   
	end 

end


/*---------------------------------------------------------
   Name: gamemode:CreateEntityRagdoll( entity, ragdoll )
   Desc: A ragdoll of an entity has been created
---------------------------------------------------------*/
function GM:CreateEntityRagdoll( entity, ragdoll )
end


// Set the ServerName every 2 seconds in case it changes..
local function HostnameThink()

	SetGlobalString( "ServerName", GetConVarString( "hostname" ) )

end

timer.Create( "HostnameThink", 2, 0, HostnameThink )

/*---------------------------------------------------------
	Show the default team selection screen
---------------------------------------------------------*/
function GM:ShowTeam( ply )

	if (!self.TeamBased) then return end
	
	// For clientside see cl_pickteam.lua
	ply:SendLua( "GAMEMODE:ShowTeam()" )

end

function GM:ShowHelp( ply )

	RunConsoleCommand( "pb_playermenu" )
	
end

function GM:SetupPlayerVisibility(ply) 
 	AddOriginToPVS(Vector(0,0,0)) 
end 

function ccWeather( ply, cmd, args )

	if args[1] == "1" then
		ply:SetNWInt( "pbweather", 1 )
	elseif args[1] == "0" then
		ply:SetNWInt( "pbweather", 0 )
	end
	
end
concommand.Add( "pb_weather", ccWeather )

function ccSetModel( ply, cmd, args )

	ply:SetNWString( "pmodel", args[1] )
	ply:KillSilent()
	
end
concommand.Add( "pb_setmodel", ccSetModel )


