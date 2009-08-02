AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

schdPatrol_Gang = ai_schedule.New( "AIFighter Chase" )
schdChase_Gang = ai_schedule.New( "AIFighter Chase" )
schdCorpse_Gang = ai_schedule.New( "AIFighter Chase" )

function ENT:TaskStart_FindEnemySmart ( data ) end
function ENT:Task_CheckEnemyDead ( ) end
function ENT:Task_ResetPatrol ( ) end

function ENT:Task_FindEnemySmart ( data )
	
	local et =  ents.FindInSphere( self:GetPos(), data.Radius or 512 )

	for k, v in pairs(et) do
		
		if v:IsValid() and v != self and v:GetClass() == data.Class then
			local trace = {}
			trace.endpos = v:GetPos() 
			trace.start = self:GetPos()
			trace.filter = self
			 
			local tr = util.TraceLine( trace ) 
			
			if not tr.Hit or (tr.Entity and tr.Entity == v) then
				self:SetEnemy(v, true)
				self:UpdateEnemyMemory(v, v:GetPos())
				self:TaskComplete()
				self:StartSchedule(schdChase)
				return
			end
		end
	end
	
	self:StartSchedule(schdPatrol)
end

function ENT:TaskStart_CheckEnemyDead ( )
	self:TaskComplete()
	
	if self:GetEnemy() == nil or not self:GetEnemy():IsValid() or self:GetEnemy():Health() <= 0 then
		self:StartSchedule(schdCorpse)
		self.Entity:EmitSound(Sound("vo/npc/male01/watchwhat.wav"), 100, 100)
		self:SetEnemy(nil, false)
		return
	end
	
	self:StartSchedule(schdChase)
end

function ENT:TaskStart_ResetPatrol ( )
	self:TaskComplete()
	self:StartSchedule(schdPatrol)
end
	
	
	schdPatrol_Gang:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE", 	128 )
	schdPatrol_Gang:EngTask( "TASK_WALK_PATH", 				0 )
	schdPatrol_Gang:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
	schdPatrol_Gang:AddTask( "FindEnemySmart", 				{Class = "rp_police", Radius = 2048} )
	
	schdChase_Gang:EngTask( "TASK_GET_PATH_TO_RANGE_ENEMY_LKP_LOS", 	0 )
	schdChase_Gang:EngTask( "TASK_RUN_PATH", 				0 )
	schdChase_Gang:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
	schdChase_Gang:EngTask( "TASK_STOP_MOVING", 			0 )
	schdChase_Gang:EngTask( "TASK_FACE_ENEMY", 			0 )
	schdChase_Gang:EngTask( "TASK_ANNOUNCE_ATTACK", 			0 )
	schdChase_Gang:EngTask( "TASK_RANGE_ATTACK1", 		0 )
	schdChase_Gang:AddTask("CheckEnemyDead", 0)
	
	
	schdCorpse_Gang:EngTask( "TASK_RELOAD", 		0 )
	schdCorpse_Gang:EngTask( "TASK_GET_PATH_TO_ENEMY_CORPSE", 	0 )
	schdCorpse_Gang:EngTask( "TASK_WALK_PATH", 				0 )
	schdCorpse_Gang:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	0 )
	schdCorpse_Gang:AddTask("ResetPatrol", 0)
	
	
function ENT:Think()
	if self:GetEnemy() == nil then return end
	self:UpdateEnemyMemory( self:GetEnemy(), self:GetEnemy():GetPos() )
	
	local trace = {}
	trace.endpos = self:GetEnemy():GetPos() 
	trace.start = self:GetPos()
	trace.filter = self
			 
	local tr = util.TraceLine( trace ) 
			
	if tr.Hit and tr.Entity != self:GetEnemy() then
		self:StartSchedule(schdChase_Gang)
	end
end
	

function ENT:Initialize()
	self:SetModel( "models/Humans/Group03/male_0" .. tostring(math.random(3, 4)) .. ".mdl" )
	
	self:SetHullType( HULL_HUMAN );
	self:SetHullSizeNormal();
	
	self:SetSolid( SOLID_BBOX )
	self:SetMoveType( MOVETYPE_STEP )
	
	self:CapabilitiesAdd( CAP_MOVE_GROUND | CAP_OPEN_DOORS | CAP_ANIMATEDFACE | CAP_TURN_HEAD | CAP_USE_SHOT_REGULATOR | CAP_AIM_GUN )
	
	self:SetMaxYawSpeed( 5000 )
	
	self:SetHealth(100)
	
	self:Give( "npc_glock" )

end


function ENT:OnTakeDamage ( dmg )
	self:SetHealth(self:Health() - dmg:GetDamage())
	
	if self:Health() <= 0 then
		local ragdoll = ents.Create( "prop_ragdoll" )
		ragdoll:SetPos( self.Entity:GetPos() )
		ragdoll:SetModel( self.Entity:GetModel() )
		ragdoll:Spawn()
		ragdoll:Activate()
		ragdoll:GetPhysicsObject():SetVelocity(Vector(0, 500, 0))
		RPNPCS_AddRagdoll(ragdoll, self:GetTable().StartPos, self:GetTable().RespawnWhenDead, "ai_rp_gangster", self:GetTable().StartHealth)
		self.Entity:Remove()
		return
	end
	
	if dmg:GetAttacker() and dmg:GetAttacker():IsValid() and self:GetEnemy() == nil then
		self:SetEnemy(dmg:GetAttacker(), true )
		self:UpdateEnemyMemory(dmg:GetAttacker(), dmg:GetAttacker():GetPos() )
		self:StartSchedule(schdChase)
	end
end 

/*---------------------------------------------------------
   Name: SelectSchedule
---------------------------------------------------------*/
function ENT:SelectSchedule()

	self:StartSchedule( schdPatrol_Gang )

end
