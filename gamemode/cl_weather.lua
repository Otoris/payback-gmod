local WEATHER={
	["sunny"]={
		Brightness=0,
		Contrast=1,
		Colour=1,
		Precipitation=0,
	},
	["cloudy"]={
		Brightness=0,
		Contrast=1,
		Colour=0.6,
		Precipitation=0,
	},
	["rain"]={
		Brightness=-0.07,
		Contrast=0.9,
		Colour=0.4,
		Precipitation=10,
		Sound="ambient/weather/rumble_rain_nowind.wav"
	},
	["sunnyrain"]={
		Brightness=0,
		Contrast=0.7,
		Colour=1.2,
		Precipitation=10,
		Sound="ambient/weather/rumble_rain_nowind.wav"
	},
	["storm"]={
		Brightness=-0.15,
		Contrast=0.7,
		Colour=0.1,
		Precipitation=20,
		Sound="ambient/weather/rumble_rain.wav"
	},
	["dark"]={
		Brightness=0,
		Contrast=0.3,
		Colour=1,
		Precipitation=0,
	},
	["darkrain"]={
		Brightness=0,
		Contrast=0.3,
		Colour=1,
		Precipitation=5,
		Sound="ambient/weather/rumble_rain_nowind.wav"
	},
}

local CurWeather={
		Brightness=0,
		Contrast=1,
		Colour=1,
}

SetGlobalString("weather","sunny")

local WeatherSound=nil
local PrevWeather="sunny"
local LastLightning=0

function WeatherOverlay()
	if LocalPlayer():GetNWInt( "pbweather" ) == 0 then return; end
	if render.GetDXLevel() < 80 then return; end

	local WeatherName=GetGlobalString("weather")
	
	if not WeatherName or not WEATHER[WeatherName] then WeatherName="sunny" end
	
	local traced = {}
	traced.start = LocalPlayer():GetPos()
	traced.endpos = LocalPlayer():GetPos()+Vector(0,0,700)
	traced.mask = MASK_NPCWORLDSTATIC
	local tr=util.TraceLine(traced)
	
	if tr.HitWorld then
		CurWeather.Brightness=math.Approach( CurWeather.Brightness, math.Clamp(WEATHER[WeatherName].Brightness,0,5), 0.01 )
		CurWeather.Contrast=math.Approach( CurWeather.Contrast, math.Clamp(WEATHER[WeatherName].Contrast,1,5), 0.01 )
		CurWeather.Colour=math.Approach( CurWeather.Colour, math.Clamp(WEATHER[WeatherName].Colour,1,5), 0.01 )
	else
	
		CurWeather.Brightness=math.Approach( CurWeather.Brightness, WEATHER[WeatherName].Brightness, 0.01 )
		CurWeather.Contrast=math.Approach( CurWeather.Contrast, WEATHER[WeatherName].Contrast, 0.01 )
		CurWeather.Colour=math.Approach( CurWeather.Colour, WEATHER[WeatherName].Colour, 0.01 )
	
	end

	local ScrColTab = {}
	ScrColTab[ "$pp_colour_addr" ] 		= 0
	ScrColTab[ "$pp_colour_addg" ] 		= 0
	ScrColTab[ "$pp_colour_addb" ] 		= 0
	ScrColTab[ "$pp_colour_brightness" ]= CurWeather.Brightness
	ScrColTab[ "$pp_colour_contrast" ] 	= CurWeather.Contrast
	ScrColTab[ "$pp_colour_colour" ] 	= CurWeather.Colour
	ScrColTab[ "$pp_colour_mulr" ] 		= 0
	ScrColTab[ "$pp_colour_mulg" ] 		= 0
	ScrColTab[ "$pp_colour_mulb" ] 		= 0
	DrawColorModify(ScrColTab)
	
	if not PrevWeather or PrevWeather~=WeatherName then
		if WeatherSound then WeatherSound:Stop() end
		if WEATHER[WeatherName].Sound then
			WeatherSound=CreateSound(LocalPlayer(),WEATHER[WeatherName].Sound)
			WeatherSound:Play()
			PrevWeather=WeatherName
		else
			WeatherSound=nil
		end
	end
	
	if CurTime()>LastLightning and  WEATHER[WeatherName].Precipitation>10 then
		if math.random(1,20)==10 then
			LastLightning=CurTime()+30
			CurWeather.Contrast=5
			timer.Simple(0.2,function()
				CurWeather.Contrast=WEATHER[WeatherName].Contrast
			end)
			timer.Simple(3,function()
				surface.PlaySound(Format("ambient/atmosphere/thunder%i.wav",math.random(1,4)))
			end)
		end
	end
	
	if WeatherSound and tr.HitWorld or (WeatherSound and LocalPlayer():InVehicle()) then
		WeatherSound:SetSoundLevel(2)
		WeatherSound:ChangePitch(50)
	elseif WeatherSound then
		WeatherSound:SetSoundLevel(3.9)
		WeatherSound:ChangePitch(100)
	end

end
hook.Add("RenderScreenspaceEffects", "WeatherOverlay", WeatherOverlay)

local LastEffect=0
function WeatherThink()
if LocalPlayer():GetNWInt( "pbweather" ) == 0 then return; end
	local WeatherName=GetGlobalString("weather")
	if not WeatherName or not WEATHER[WeatherName] then WeatherName="sunny" end
	if WEATHER[WeatherName].Precipitation>0 then
		if CurTime()>LastEffect then
			LastEffect=CurTime()+1
			local eff=EffectData()
				eff:SetMagnitude(WEATHER[WeatherName].Precipitation)
			util.Effect("rain",eff)
		end
	end
end
hook.Add("Think","",WeatherThink)
