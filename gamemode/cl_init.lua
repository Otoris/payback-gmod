

include( 'shared.lua' )
include( 'cl_weather.lua' )
include( 'cl_scoreboard.lua' )
include( 'cl_targetid.lua' )
include( 'cl_hudpickup.lua' )
include( 'cl_spawnmenu.lua' )
include( 'cl_deathnotice.lua' )
include( 'cl_pickteam.lua' )

gmod_vehicle_viewmode = CreateClientConVar( "gmod_vehicle_viewmode", "1", true, true )

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

	GAMEMODE.ShowScoreboard = false
	
	surface.CreateFont( "coolvetica", 48, 500, true, false, "ScoreboardHead" )
	surface.CreateFont( "coolvetica", 24, 500, true, false, "ScoreboardSub" )
	surface.CreateFont( "Tahoma", 16, 1000, true, false, "ScoreboardText" )
	surface.CreateFont( "FARCRY", 46, 500, true, false, "scorefont" )
	surface.CreateFont( "28 days later", 46, 500, true, false, "paybackfont2" )
	
	
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
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies. If the attacker was
		  a player then attacker will become a Player instead
		  of an Entity. 		 
---------------------------------------------------------*/
function GM:PlayerDeath( ply, attacker )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerBindPress( )
   Desc: A player pressed a bound key - return true to override action		 
---------------------------------------------------------*/
function GM:PlayerBindPress( pl, bind, down )

	// If we're driving, toggle third person view using duck
	if ( down && bind == "+duck" && ValidEntity( pl:GetVehicle() ) ) then
	
		local iVal = gmod_vehicle_viewmode:GetInt()
		if ( iVal == 0 ) then iVal = 1 else iVal = 0 end
		RunConsoleCommand( "gmod_vehicle_viewmode", iVal )
		return true
		
	end

	return false	
	
end

/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
---------------------------------------------------------*/
function GM:HUDShouldDraw( name )

 	for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do 
 		if name == v then return false end 
 	end 
	// Allow the weapon to override this
	local ply = LocalPlayer()
	if (ply && ply:IsValid()) then
	
		local wep = ply:GetActiveWeapon()
		
		if (wep && wep:IsValid() && wep.HUDShouldDraw != nil) then
		
			return wep.HUDShouldDraw( wep, name )
			
		end
		
	end

	return true;
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
---------------------------------------------------------*/

function GM:HUDPaint()
	score = LocalPlayer():GetNWString( "MEPOINTS" )
	local length = string.len(score) --Credit for formating the score goes to ZeikJT 
	if length < 8 then
		for i = 1, 8 - length do
		score = "0"..score
		end
	end
	draw.DrawText( score, "scorefont", ScrW() - 200, 10, Color( 255, 255, 255, 255 ), 3 )
	--GAMEMODE:HUDDrawTargetID()
	--GAMEMODE:HUDDrawPickupHistory()
	--GAMEMODE:DrawDeathNotice( 0.85, 0.04 )
	
 	local heart = surface.GetTextureID( "payback/heart" )
 	-- CityNameTable.texture 	= 
 	-- CityNameTable.color		= Color( 255, 255, 255, 0 ) 
 	local hp = LocalPlayer():Health()
 	-- CityNameTable.x = ScrW() / 2 
 	-- CityNameTable.y = ScrH() / 2
 	-- CityNameTable.w = 512 
 	-- CityNameTable.h = 32
	-- draw.TexturedQuad( CityNameTable )
	--draw.RoundedBox( 2, ScrW() / 2 - 256, ScrH() / 4, 512, 32, Color( 0, 0, 0, 190 ) );ScrW() -100, ScrH() / 2, 16, 16	
	heart5 = {}
	heart5.texture = heart
	heart5.x = ScrW() - 28
	heart5.y = 60
	heart5.w = 16
	heart5.h = 16
	heart5.color = Color( 255, 255, 255, 255 )	

	heart4 = {}
	heart4.texture = heart
	heart4.x = ScrW() - 46
	heart4.y = 60
	heart4.w = 16
	heart4.h = 16
	heart4.color = Color( 255, 255, 255, 255 )
	
	heart3 = {}
	heart3.texture = heart
	heart3.x = ScrW() - 64
	heart3.y = 60
	heart3.w = 16
	heart3.h = 16
	heart3.color = Color( 255, 255, 255, 255 )
	
	heart2 = {}
	heart2.texture = heart
	heart2.x = ScrW() - 82
	heart2.y = 60
	heart2.w = 16
	heart2.h = 16
	heart2.color = Color( 255, 255, 255, 255 )
	
	heart1 = {}
	heart1.texture = heart
	heart1.x = ScrW() - 100
	heart1.y = 60
	heart1.w = 16
	heart1.h = 16
	heart1.color = Color( 255, 255, 255, 255 )
	if LocalPlayer():Alive() then
	draw.TexturedQuad( heart1 )
		if hp >= 100 or hp < 100 and hp >= 80 then
			draw.TexturedQuad( heart5 )
			draw.TexturedQuad( heart4 )
			draw.TexturedQuad( heart3 )
			draw.TexturedQuad( heart2 )
			--draw.TexturedQuad( heart1 )
		elseif hp >= 60 and hp < 80 then
			draw.TexturedQuad( heart4 )
			draw.TexturedQuad( heart3 )
			draw.TexturedQuad( heart2 )
		elseif hp >= 40 and hp < 60 then
			draw.TexturedQuad( heart3 )
			draw.TexturedQuad( heart2 )
		elseif hp >= 20 and hp < 40 then
			draw.TexturedQuad( heart2 )
		end
	
	
	end
	
	if drawblackbox == true then
		draw.RoundedBox( 8, ScrW() / 2 - 250, ScrH() / 2 - 250, 500, 500, Color( 0, 0, 0, 255 ) )
		draw.DrawText( "PAYBACK", "paybackfont2", ScrW() / 2 + 150, ScrH() / 2 - 300, Color( 255, 194, 67, 255 ), 1 )
		draw.RoundedBox( 8, ScrW() / 2 + 10, ScrH() / 2 + 130, 150, 82, Color( 0, 0, 255, 7 ) )
	end
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaintBackground( )
   Desc: Same as HUDPaint except drawn before
---------------------------------------------------------*/
function GM:HUDPaintBackground()
end

/*---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
---------------------------------------------------------*/
function GM:CreateMove( cmd )

	local ang = cmd:GetViewAngles()
	ang.p = 0
	
	cmd:SetUpMove(0)
	cmd:SetViewAngles( ang )

	if cmd:KeyDown(IN_DUCK) then
		LocalPlayer():ConCommand("-duck")
	end
	
end

/*---------------------------------------------------------
   Name: gamemode:CallScreenClickHook( bDown, mousecode, AimVector )
   Desc: Called when clicked on the screen, 
---------------------------------------------------------*/
function GM:CallScreenClickHook( bDown, mousecode, AimVector )

	local i = 0
	if ( bDown ) then i = 1 end
	
	// Tell the server that we clicked on the screen so it can actually do stuff.
	RunConsoleCommand( "cnc", i, mousecode, AimVector.x, AimVector.y, AimVector.z )
	
	// And let us predict it clientside
	hook.Call( "ContextScreenClick", GAMEMODE, AimVector, mousecode, bDown, LocalPlayer() )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMousePressed( mousecode )
   Desc: The mouse has been pressed on the game screen
---------------------------------------------------------*/
function GM:GUIMousePressed( mousecode, AimVector )

	hook.Call( "CallScreenClickHook", GAMEMODE, true, mousecode, AimVector )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse has been released on the game screen
---------------------------------------------------------*/
function GM:GUIMouseReleased( mousecode, AimVector )

	hook.Call( "CallScreenClickHook", GAMEMODE, false, mousecode, AimVector )

end

/*---------------------------------------------------------
   Name: gamemode:GUIMouseReleased( mousecode )
   Desc: The mouse was double clicked
---------------------------------------------------------*/
function GM:GUIMouseDoublePressed( mousecode, AimVector )
	// We don't capture double clicks by default, 
	// We just treat them as regular presses
	GAMEMODE:GUIMousePressed( mousecode, AimVector )
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end


/*---------------------------------------------------------
   Name: gamemode:RenderScreenspaceEffects( )
   Desc: Bloom etc should be drawn here (or using this hook)
---------------------------------------------------------*/
function GM:RenderScreenspaceEffects()
end

/*---------------------------------------------------------
   Name: gamemode:GetTeamColor( ent )
   Desc: Return the color for this ent's team
		This is for chat and deathnotice text
---------------------------------------------------------*/
function GM:GetTeamColor( ent )

	local team = TEAM_UNASSIGNED
	if (ent.Team) then team = ent:Team() end
	return GAMEMODE:GetTeamNumColor( team )

end


/*---------------------------------------------------------
   Name: gamemode:GetTeamNumColor( num )
   Desc: returns the colour for this team num
---------------------------------------------------------*/
function GM:GetTeamNumColor( num )

	return team.GetColor( num )

end

/*---------------------------------------------------------
   Name: gamemode:OnChatTab( str )
   Desc: Tab is pressed when typing (Auto-complete names, IRC style)
---------------------------------------------------------*/
function GM:OnChatTab( str )

	local LastWord
	for word in string.gmatch( str, "%a+" ) do
	     LastWord = word;
	end
	
	if (LastWord == nil) then return str end
	
	playerlist = player.GetAll()
	
	for k, v in pairs( playerlist ) do
		
		local nickname = v:Nick()
		
		if ( string.len(LastWord) < string.len(nickname) &&
			 string.find( string.lower(nickname), string.lower(LastWord) ) == 1 ) then
				
			str = string.sub( str, 1, (string.len(LastWord) * -1) - 1)
			str = str .. nickname
			return str
			
		end		
		
	end
		
	return str;

end

/*---------------------------------------------------------
   Name: gamemode:StartChat( teamsay )
   Desc: Start Chat.
   
		 If you want to display your chat shit different here's what you'd do:
			In StartChat show your text box and return true to hide the default
			Update the text in your box with the text passed to ChatTextChanged
			Close and clear your text box when FinishChat is called.
			Return true in ChatText to not show the default chat text
			
---------------------------------------------------------*/
function GM:StartChat( teamsay )
	return false
end

/*---------------------------------------------------------
   Name: gamemode:FinishChat()
---------------------------------------------------------*/
function GM:FinishChat()
end

/*---------------------------------------------------------
   Name: gamemode:ChatTextChanged( text)
---------------------------------------------------------*/
function GM:ChatTextChanged( text )
end


/*---------------------------------------------------------
   Name: ChatText
   Allows override of the chat text
---------------------------------------------------------*/
function GM:ChatText( playerindex, playername, text, filter )

	if ( filter == "chat" ) then
		Msg( playername, ": ", text, "\n" )
	else
		Msg( text, "\n" )
	end
	
	return false

end

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function GM:GetSWEPMenu()

	local columns = {}
	columns[ 1 ] = "#Name"
	columns[ 2 ] = "#Author"
	columns[ 3 ] = "#Admin"
	
	local ret = {}
	
	table.insert( ret, columns )

	local weaponlist = weapons.GetList()
	
	for k,v in pairs( weaponlist ) do
	
		if ( v.Spawnable || v.AdminSpawnable ) then
		
			local entry = {}
			entry[ 1 ] 	= v.PrintName
			entry[ 2 ] 	= v.Author
			if ( v.AdminSpawnable && !v.Spawnable ) then entry[ 3 ]  = "ADMIN ONLY" else entry[ 3 ]  = "" end
			entry[ "command" ]  = "gm_giveswep "..v.Classname
			
			table.insert( ret, entry )		
		
		end
	
	end

	return ret

end

/*---------------------------------------------------------
   Name: 
---------------------------------------------------------*/
function GM:GetSENTMenu()

	local columns = {}
	columns[ 1 ] = "#Name"
	columns[ 2 ] = "#Author"
	columns[ 3 ] = "#Admin"
	
	local ret = {}
	
	table.insert( ret, columns )

	local entlist = scripted_ents.GetList()
	
	for k,v in pairs( entlist ) do
	
		if ( v.t.Spawnable || v.t.AdminSpawnable ) then
		
			local entry = {}
			entry[ 1 ] 	= v.t.PrintName
			entry[ 2 ] 	= v.t.Author
			if ( v.t.AdminSpawnable && !v.t.Spawnable ) then entry[ 3 ]  = "ADMIN ONLY" else entry[ 3 ]  = "" end
			entry[ "command" ]  = "gm_spawnsent "..v.t.Classname
			
			table.insert( ret, entry )		
		
		end
	
	end

	return ret

end

/*---------------------------------------------------------
   Name: gamemode:PostProcessPermitted( str )
   Desc: return true/false depending on whether this post process should be allowed
---------------------------------------------------------*/
function SetViewClientCorpse( msg )
	ViewCorpse = msg:ReadBool()
end
usermessage.Hook("SetViewClientCorpse",SetViewClientCorpse) 

function GM:PostProcessPermitted( str )

	return true

end


/*---------------------------------------------------------
   Name: gamemode:PostRenderVGUI( )
   Desc: Called after VGUI has been rendered
---------------------------------------------------------*/
function GM:PostRenderVGUI()
end


/*---------------------------------------------------------
   Name: gamemode:GetVehicles( )
   Desc: Gets the vehicles table..
---------------------------------------------------------*/
function GM:GetVehicles()

	return vehicles.GetTable()
	
end

/*---------------------------------------------------------
   Name: gamemode:RenderScene( )
   Desc: Render the scene
---------------------------------------------------------*/
function GM:RenderScene()
end

/*---------------------------------------------------------
   Name: CalcVehicleThirdPersonView
---------------------------------------------------------*/
function GM:CalcVehicleThirdPersonView( Vehicle, ply, origin, angles, fov )

	local view = {}
	view.angles		= angles
	view.fov 		= fov
	
	if ( !Vehicle.CalcView ) then
	
		Vehicle.CalcView = {}
		
		// Try to work out the size
		local min, max = Vehicle:WorldSpaceAABB()
		local size = max - min
		
		Vehicle.CalcView.OffsetUp = size.z
		Vehicle.CalcView.OffsetOut = (size.x + size.y + size.z) * 0.33
	
	end
	
	// Offset the origin
	local Up = view.angles:Up() * Vehicle.CalcView.OffsetUp * 0.66
	local Offset = view.angles:Forward() * -Vehicle.CalcView.OffsetOut
	
	// Trace back from the original eye position, so we don't clip through walls/objects
	local TargetOrigin = Vehicle:GetPos() + Up + Offset
	local distance = origin - TargetOrigin
	
	local trace = {
					start = origin,
					endpos = TargetOrigin,
					filter = Vehicle
				  }
				  
				  
	local tr = util.TraceLine( trace ) 
	
	view.origin = origin + tr.Normal * (distance:Length() - 10) * tr.Fraction
		
	return view

end

/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angle, fov )

	local ang = ply:GetAimVector():Angle()
	ang.p = 90
	ang.r = 0

	if not ply:Alive() then
		local corpse = LocalPlayer():GetRagdollEntity()
		if corpse and corpse:IsValid() then
			local view = {}
			view.origin = corpse:GetPos() + Vector(0,0,1000)
			view.angles = ang
			return view
		else
			local view = {}
			view.origin = ply:GetPos() + Vector(300,0,1000)
			view.angles = ang
			return view
		end
	end
	
	local aimvec = ply:GetAimVector():Angle()
	aimvec.r = 0
	aimvec.p = 0
	
	local wep = ply:GetActiveWeapon()
	if not wep or wep == NULL then
		ply.Adjust = math.Approach(ply.Adjust or 0,0,3)
	elseif wep:GetClass() == "civilian_hands" then
		ply.Adjust = math.Approach(ply.Adjust or 0,0,3)
	else
		ply.Adjust = math.Approach(ply.Adjust or 0,300,3)
	end

	local view = {}
	view.origin = ply:GetPos() + Vector(0,0,1000) + aimvec:Forward() * ply.Adjust
	view.angles = ang
	return view

end

/*---------------------------------------------------------
   Name: gamemode:AdjustMouseSensitivity()
   Desc: Allows you to adjust the mouse sensitivity.
		 The return is a fraction of the normal sensitivity (0.5 would be half as sensitive)
		 Return -1 to not override.
---------------------------------------------------------*/
function GM:AdjustMouseSensitivity( fDefault )

	local ply = LocalPlayer()
	if (!ply || !ply:IsValid()) then return -1 end

	local wep = ply:GetActiveWeapon()
	if ( wep && wep.AdjustMouseSensitivity ) then
		return wep:AdjustMouseSensitivity()
	end

	return -1
	
end



function PBMENU( ply )

	drawblackbox = true

	DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetSize( 500, 500 )
	--DermaPanel:SetPos( ScrW() / 2 - 250, ScrH() / 2 - 250 )
	DermaPanel:SetTitle( "" )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( false )
	DermaPanel.Paint = function()
		surface.SetDrawColor( 0, 0, 0, 255 )
	end
	
	local astrisk = vgui.Create( "DLabel", DermaPanel )
	astrisk:SetPos( 255, 8 )
	astrisk:SetText( "*" )
	
	local StatsList = vgui.Create( "DListView", DermaPanel )
	StatsList:SetSize( 100, 85 )
	StatsList:SetPos( 260, 20 )
	StatsList:SetMultiSelect( false )
	StatsList:AddColumn("Stats")
	StatsList:AddLine( KEVLAR[1] )
	StatsList:AddLine( ST[1] )
	StatsList:AddLine( SP[1] )
	StatsList:AddLine( E[1] )	
	
	local StatsList2 = vgui.Create( "DListView", DermaPanel )
	StatsList2:SetSize( 100, 85 )
	StatsList2:SetPos( 380, 20 )
	StatsList2:SetMultiSelect( false )
	StatsList2:AddColumn("Description")
	StatsList2:AddLine( Eyes[1] )
	StatsList2:AddLine( Weight[1] )
	StatsList2:AddLine( HColor[1] )
	StatsList2:AddLine( FSize[1] )	
	
	local ScoreBoard = vgui.Create( "DListView", DermaPanel )
	ScoreBoard:SetSize( 220, 250 )
	ScoreBoard:SetPos( 260, 120 )
	ScoreBoard:SetMultiSelect( false )
	ScoreBoard:AddColumn("Players")
	ScoreBoard:AddColumn("Score")
	ScoreBoard:AddColumn("Ping")
	for k,v in pairs(player.GetAll()) do 
		ScoreBoard:AddLine(v:Nick(), v:GetNWString( "MEPOINTS" ), v:Ping()) // Add lines 
	end  
	ScoreBoard:SortByColumn( 1, true )
	

	
		
		-- local mdlPanelList = vgui.Create( "DPanelList" )
		-- mdlPanelList:SetParent( DermaPanel )
		-- mdlPanelList:SetSize( 480, 280 )
		-- mdlPanelList:SetPos( 10, 10 )
		-- mdlPanelList:SetSpacing( 8 )
		-- mdlPanelList:EnableHorizontal( false )
		-- mdlPanelList.Paint = function()
			-- surface.SetDrawColor( 0, 0, 0, 0 )
		-- end
		
		-- local mdlSelect = vgui.Create( "DMultiChoice", DermaPanel )
		-- mdlSelect:SetEditable( false )
		-- for k, v in pairs( mdlList ) do
			-- mdlSelect:AddChoice( v )
		-- end
		local mdlName = vgui.Create( "DLabel", DermaPanel )
		mdlName:SetPos( 110, 450 )
		mdlName:SetText( nameList[1] )
		
		local mdlPanel = vgui.Create( "DModelPanel", DermaPanel )
		mdlPanel:SetSize( 650, 650 )
		mdlPanel:SetPos( -205, -205 )
		mdlPanel:SetModel( mdlList[1] )
		mdlPanel:SetAnimSpeed( 0.0 )
		mdlPanel:SetAnimated( false )
		mdlPanel:SetAmbientLight( Color( 50, 50, 50 ) )
		mdlPanel:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
		mdlPanel:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )
		mdlPanel:SetCamPos( Vector( 100, 0, 40 ) )
		mdlPanel:SetLookAt( Vector( 0, 0, 40 ) )
		mdlPanel:SetFOV( 70 )
		
		function mdlPanel:LayoutEntity(Entity)

			self:RunAnimation();
			Entity:SetAngles( Angle( 0, 0, 0) )
		
		end
		
		local name = 1
		local i = 1
		
		local kv = 1
		local stg = 1
		local spe = 1
		local en = 1
		
		local eye = 1
		local we = 1
		local hair = 1
		local foot = 1
		
		local LastMdl = vgui.Create( "DSysButton", DermaPanel )
		LastMdl:SetType("left")
		LastMdl.DoClick = function()
		
			i = i - 1
			name = name - 1
			
			kv = kv - 1
			stg = stg - 1
			spe = spe - 1
			en = en - 1
			
			eye = eye - 1
			we = we - 1
			hair = hair - 1
			foot = foot - 1
			
			if( i == 0 ) then
				i = #mdlList
			end
		
			if( name == 0 ) then
				name = #nameList
			end
			
			if( kv == 0 ) then
				kv = #KEVLAR
			end
			
			if( stg == 0 ) then
				stg = #ST
			end
			
			if( spe == 0 ) then
				spe = #SP
			end
			
			if( en == 0 ) then
				en = #E
			end
			
			if( eye == 0 ) then
				eye = #Eyes
			end
			
			if( we == 0 ) then
				we = #Weight
			end
			
			if( hair == 0 ) then
				hair = #HColor
			end
			
			if( foot == 0 ) then
				foot = #FSize
			end
			mdlName:SetText( nameList[name] )
			mdlPanel:SetModel(mdlList[i])
			
			StatsList:Clear()
			StatsList:AddLine( KEVLAR[kv] )
			StatsList:AddLine( ST[stg] )
			StatsList:AddLine( SP[spe] )
			StatsList:AddLine( E[en] )
		
			StatsList2:Clear()
			StatsList2:AddLine( Eyes[eye] )
			StatsList2:AddLine( Weight[we] )
			StatsList2:AddLine( HColor[hair] )
			StatsList2:AddLine( FSize[foot] )
			
		end

		LastMdl:SetPos( 30, 450 )

		local NextMdl = vgui.Create( "DSysButton", DermaPanel )
		NextMdl:SetType("right")
		NextMdl.DoClick = function()

		i = i + 1
		name = name + 1
		
		kv = kv + 1
		stg = stg + 1
		spe = spe + 1
		en = en + 1
		
		eye = eye + 1
		we = we + 1
		hair = hair + 1
		foot = foot + 1
		
		if(i > #mdlList) then
			i = 1
		end
		
		if(name > #nameList) then
			name = 1
		end
		
		if(kv > #KEVLAR) then
			kv = 1
		end
		
		if(stg > #ST) then
			stg = 1
		end
		
		if(spe > #SP) then
			spe = 1
		end
		
		if(en > #E) then
			en = 1
		end
		
		if(eye > #Eyes) then
			eye = 1
		end
		
		if(we > #Weight) then
			we = 1
		end
		
		if(hair > #HColor) then
			hair = 1
		end
		
		if(foot > #FSize) then
			foot = 1
		end
		
		mdlName:SetText( nameList[name] )
		mdlPanel:SetModel(mdlList[i])
		
		StatsList:Clear()
		StatsList:AddLine( KEVLAR[kv] )
		StatsList:AddLine( ST[stg] )
		StatsList:AddLine( SP[spe] )
		StatsList:AddLine( E[en] )

		StatsList2:Clear()
		StatsList2:AddLine( Eyes[eye] )
		StatsList2:AddLine( Weight[we] )
		StatsList2:AddLine( HColor[hair] )
		StatsList2:AddLine( FSize[foot] )
		
	end
		NextMdl:SetPos( 150, 450 )
		
		

	local RadioCheck = vgui.Create( "DCheckBoxLabel", DermaPanel )
	RadioCheck:SetText( "Radio" )
	RadioCheck:SetPos( 420, 380 )
	RadioCheck:SetValue( 1 )

	local WeatherCheck = vgui.Create( "DCheckBoxLabel", DermaPanel )
	WeatherCheck:SetText( "Weather" )
	WeatherCheck:SetPos( 420, 400 )
	WeatherCheck:SetValue( 1 )
	
	local lol = vgui.Create( "DLabel", DermaPanel )
	lol:SetPos( 260, 470 )
	lol:SetSize( 1000, 22 )
	lol:SetText( "* For show and concept purposes only!" )
	
		local applybutton = vgui.Create( "DButton" )
		applybutton:SetParent( DermaPanel )
		applybutton:SetText( "Apply" )
		applybutton:SetSize( 60, 40 )
		applybutton:SetPos( 420, 420 )
		applybutton.DoClick = function()
		drawblackbox = false
		if RadioCheck:GetChecked() == true and !RadioOn then
			PBRADIO()
		elseif RadioCheck:GetChecked() == false and RadioOn == true then
			RadioOn = false
			RadioFrame:OpenURL( "http://www.duke.edu/~zjt3/" )
		end
		if WeatherCheck:GetChecked() then
			RunConsoleCommand( "pb_weather", "1" )
		else
			RunConsoleCommand( "pb_weather", "0" )
			RunConsoleCommand( "stopsounds" )
		end
		RunConsoleCommand( "pb_setmodel", mdlList[i] )
		DermaPanel:Close()
		end
		
		DermaPanel:Center()
		DermaPanel:SetScreenLock( true )		
		DermaPanel:MakePopup()

		-- mdlPanelList:AddItem( mdlPanel )
		-- mdlPanelList:AddItem( mdlSelect )
end
concommand.Add( "pb_playermenu", PBMENU )

function PBRADIO( ply )

	RadioPanel = vgui.Create( "DPanel" )
	RadioPanel:SetSize( 110, 110 )
	RadioPanel:SetPos( -1000000, -10000 )
	--RadioPanel:MakePopup()
	
	RadioOn = true
	RadioFrame = vgui.Create( "HTML", RadioPanel )
	RadioFrame:SetSize( 100, 100 )
	RadioFrame:SetPos( 5, 5 )
	RadioFrame:OpenURL( "http://www.sourcetunes.com/players/server_player/play.php?id=default&chan=classicalternative" )

end
	
/*---------------------------------------------------------
   Name: gamemode:ForceDermaSkin()
   Desc: Return the name of skin this gamemode should use.
		 If nil is returned the skin will be determined 
			from the convar 'derma_skin'.
---------------------------------------------------------*/
function GM:ForceDermaSkin()

	//return "example"
	return nil
	
end
