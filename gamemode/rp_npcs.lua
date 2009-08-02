RPNPCS_FlaggedPlayers = {}
RPNPCS_RagdollFades = {}

function RPNPCS_AddRagdoll ( ent, pos, respawn, class, health )
	local newtable = {}
	newtable.Color = 1000
	newtable.Ent = ent
	newtable.Respawn = respawn
	newtable.Pos = pos
	newtable.Class = class
	newtable.Health = health
	table.insert(RPNPCS_RagdollFades, newtable)
end

function RPNPCS_Think ( )
	for k, v in pairs(RPNPCS_RagdollFades) do
	
		if v.Color > 510 then
			v.Ent:SetColor(255, 255, 255, 255)
		else
			v.Ent:SetColor(255, 255, 255, math.ceil(v.Color / 2))
		end
		RPNPCS_RagdollFades[k].Color = RPNPCS_RagdollFades[k].Color - 1
		
		if RPNPCS_RagdollFades[k].Color == 0 then
		
			v.Ent:Remove()
			RPNPCS_RagdollFades[k] = nil
			
			if v.Respawn then
				RPNPCS_Create(v.Class, v.Pos, true, v.Health)
			end
			
		end
	end
end
hook.Add("Think", "RPNPCS_Think", RPNPCS_Think)


function RPNPCS_Create ( class, pos, respawn, health )
	local ragdoll = ents.Create( class )
	ragdoll:Spawn()
	ragdoll:SetPos(pos)
	ragdoll:GetTable().RespawnWhenDead = respawn
	ragdoll:GetTable().StartPos = pos
	ragdoll:SetHealth(health)
	ragdoll:GetTable().StartHealth = health
	return ragdoll
end


function RPNPCS_OnPlayerDeath ( victim, inflictor, killer )
	if victim:IsValid() and killer:IsValid() then
		if killer:IsPlayer() and victim:IsPlayer() then
			table.insert(RPNPCS_FlaggedPlayers, killer)
		elseif victim:IsPlayer() and killer:GetClass() == "rp_police" then
			for k, v in pairs(RPNPCS_FlaggedPlayers) do
				if v == victim then
					RPNPCS_FlaggedPlayers[k] = nil
				end
			end
		end
	end
end
hook.Add("PlayerDeath", "RPNPCS_OnPlayerDeath", RPNPCS_OnPlayerDeath)