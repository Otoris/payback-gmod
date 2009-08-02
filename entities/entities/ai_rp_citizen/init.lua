AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Models = {"Female_01", "Female_02", "Female_03", "Female_04", "Female_06", "Female_07", "Male_01", "male_02", "male_03", "Male_04", "Male_05", "male_06", "male_07", "male_08", "male_09"}

schdPatrol_cit = ai_schedule.New( "AIFighter Chase" )
schdRun_cit = ai_schedule.New( "AIFighter Chase" )


function ENT:TaskStart_RunAway ( data ) end

function ENT:Task_RunAway ( data )
	self:StartSchedule(schdPatrol_cit)
	self.IsHiding = false
	self:TaskComplete()
end

	
	schdPatrol_cit:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	128 )
	schdPatrol_cit:EngTask( "TASK_WALK_PATH", 				0 )
	schdPatrol_cit:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )

	schdRun_cit:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	128 )
	schdRun_cit:EngTask( "TASK_RUN_PATH", 				0 )
	schdRun_cit:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
	schdRun_cit:AddTask( "PlaySequence", { Name = "ACT_COWER", Speed = 1 } )
	schdRun_cit:AddTask( "RunAway", 0)


function ENT:Initialize()

	self:SetModel( "models/Humans/Group01/" .. Models[math.random(1, table.getn(Models))] .. ".mdl" )
	
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
	
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	
	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_OPEN_DOORS | CAP_ANIMATEDFACE | CAP_TURN_HEAD | CAP_USE_SHOT_REGULATOR | CAP_AIM_GUN )
	
	self:SetMaxYawSpeed( 5000 )
		
	//self:Give( "npc_mp5" )

end

function ENT:OnTakeDamage ( dmg )
	self:SetHealth(self:Health() - dmg:GetDamage())
	
	self.IsHiding = self.IsHiding or false
	
	if not self.IsHiding then
		if string.find(string.lower(self.Entity:GetModel()), "female") then
			self.Entity:EmitSound(Sound("vo/npc/female01/pain0" .. tostring(math.random(1, 9)) .. ".wav"), 100, 100)
		else
			self.Entity:EmitSound(Sound("vo/npc/male01/pain0" .. tostring(math.random(1, 9)) .. ".wav"), 100, 100)
		end
		
		self.IsHiding = true
		self:StartSchedule( schdRun_cit )
	end
	
	if self:Health() <= 0 then
		if dmg:GetAttacker():IsPlayer() then
			table.insert(RPNPCS_FlaggedPlayers, dmg:GetAttacker())
		end
		
		local ragdoll = ents.Create( "prop_ragdoll" )
		ragdoll:SetPos( self.Entity:GetPos() )
		ragdoll:SetModel( self.Entity:GetModel() )
		ragdoll:Spawn()
		ragdoll:Activate()
		ragdoll:GetPhysicsObject():SetVelocity(Vector(0, 500, 0))
		RPNPCS_AddRagdoll(ragdoll, self:GetTable().StartPos, self:GetTable().RespawnWhenDead, "ai_rp_citizen", self:GetTable().StartHealth)
		self.Entity:Remove()
		return
	end
end 

/*---------------------------------------------------------
   Name: SelectSchedule
---------------------------------------------------------*/
function ENT:SelectSchedule()

	self:StartSchedule( schdPatrol_cit )

end
