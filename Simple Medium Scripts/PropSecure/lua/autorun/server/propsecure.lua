--[[
	PropSecure - Simple defense of props from hostile players!
--]]

local function isPhysProp(ent)
	local phys = ent:GetPhysicsObject()
	if !phys then return end
	return phys:GetMass() < 30
end

hook.Add("PlayerSpawnedProp", "PropSecure_SpawnProp", function(_, _, ent)
	if isPhysProp(ent) then
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
		end
	end
end)

hook.Add("PhysgunPickup", "PropSecure_Pickup", function(ply, ent)
	if ent:IsPlayer() then return end
	if ent:IsVehicle() then return end
	if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return end
	if ent.GetParent and IsValid(ent:GetParent()) then return end
	if constraint.HasConstraints(ent) then constraint.RemoveAll(ent) end

	ent.PhysgunPickuped = true
	ent.OldCollide = ent.OldCollide or ent:GetCollisionGroup()
	ent:SetCollisionGroup(20)

	ent.oldColor = ent:GetColor();
	ent.oldMat = ent:GetMaterial();
	
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100))
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
end)

local function freezeReal(ent)
	if ent.PhysgunPickuped then return end
	
	if (timer.Exists(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal")) then
		timer.Destroy(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal");
	end
	
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 255));
	ent:SetMaterial(ent.oldMat);
	ent:SetCollisionGroup(COLLISION_GROUP_NONE);
	ent.OldCollide = nil
end

local function waitForPlayersToLeave(ent)
	if !IsValid(ent) then return end

	if ent.PhysgunPickuped then return end
	
	timer.Create(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal", 1, 0, function()
		if ent.PhysgunPickuped then
			return
		end

		if !IsValid(ent) then return end

		local min = ent:LocalToWorld(ent:OBBMins());
		local max = ent:LocalToWorld(ent:OBBMaxs());
		local entities = ents.FindInBox(min, max);

		for k,v in ipairs(entities) do
			if (v:IsPlayer() or v:IsVehicle()) then
				return;
			end
		end		
		freezeReal(ent);
	end)
end

hook.Add("PhysgunDrop", "PropSecure_Drop", function(ply, ent)	
	if ent:IsPlayer() then return end
	ent.PhysgunPickuped = false
	if (ent:GetClass() != "prop_physics") then return end

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(Vector(0, 0, 0))
	end

	local min = ent:LocalToWorld(ent:OBBMins());
	local max = ent:LocalToWorld(ent:OBBMaxs());
	local foundEnts = ents.FindInBox(min, max);

	if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) and !ent:GetPhysicsObject():IsMotionEnabled() then
		return
	end

	for k,v in ipairs(foundEnts) do
		if v:IsPlayer() or v:IsVehicle() then
			if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():EnableMotion(false)
			end

			ent.oldColor = ent:GetColor();
			ent.oldMat = ent:GetMaterial();
			
			ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100))
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
			waitForPlayersToLeave(ent)
			return
		end
	end

	for k,v in ipairs(foundEnts) do
		if v.IsWorld and v:IsWorld() then 
			if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():EnableMotion(false)
			end
			freezeReal(ent)
			continue 
		end

		if (v != ent) and v:GetClass() == "prop_physics" then
			if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():EnableMotion(false)
			end
			freezeReal(ent)
			return
		end
	end
	freezeReal(ent)
end)

hook.Add("OnPhysgunFreeze", "PropSecure_Freeze", function(weap, physobj, ent, ply)
	ent.PhysgunPickuped = false

	if (ent:GetClass() != "prop_physics") then return; end

	local min = ent:LocalToWorld(ent:OBBMins());
	local max = ent:LocalToWorld(ent:OBBMaxs());
	local foundEnts = ents.FindInBox(min, max);
	
	for k,v in ipairs(foundEnts) do
		if (v:IsPlayer() or v:IsVehicle()) then
			ent.oldColor = ent:GetColor()
			ent.oldMat = ent:GetMaterial()
			
			ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100))
			ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
			waitForPlayersToLeave(ent);
			return;
		end
	end	
	freezeReal(ent);
end)

hook.Remove("OnEntityCreated", "PropSecure_CreateProp", function(ent)
	if (ent:GetClass() != "prop_physics") then return; end
	if !IsValid(ent:GetPhysicsObject()) then return end
	ent:GetPhysicsObject():EnableMotion(false)
end)

hook.Add("PlayerSpawnedProp", "PropSecure_SpawnProp", function(ply, mdl, ent)
	local min = ent:LocalToWorld(ent:OBBMins());
	local max = ent:LocalToWorld(ent:OBBMaxs());
	local foundEnts = ents.FindInBox(min, max);

	ent:GetPhysicsObject():EnableMotion(false)

	for k,v in ipairs(foundEnts) do
		if (v:IsPlayer() or v:GetClass() == "func_tracktrain" or v:IsVehicle()) then
			ent:Remove()
		end
	end
end)

local lastBreakPos = Vector()
local lastBreakTime = 0
hook.Remove("PropBreak", "PropSecure_AntiCrash", function(ent)
	lastBreakPos = ent:GetPos()
	lastBreakTime = CurTime()
end)

hook.Remove("EntityTakeDamage", "PropSecure_AntiCrash", function(ent, dmg)
	if ent:GetClass() == "prop_physics" and ent:Health() != 0 then end
end)

timer.Create("PropSecure_CheckPentration", 0.5, 0, function()
	for v,k in pairs(ents.GetAll()) do
		if !IsValid(k) or k:IsWorld() then continue end
		local class = k:GetClass()
		if !k.PenetrationCheck and class != "prop_physics" then continue end

		local phys = k:GetPhysicsObject()
		if IsValid(phys) then
			if phys:IsPenetrating() and phys:IsMotionEnabled() then
				if k.PenetrationCheck then
					if k.checked and k.checked > 4 then
						timer.Simple(1,function()
							if IsValid(k) then k.checked = 0 end
						end)
					else
						k.checked = (k.checked or 0) + 1
						continue
					end
				end

				phys:AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
				phys:EnableMotion(false)
				k.checked = nil
			end
		else
			k:Remove()
		end
	end
end)

hook.Add("CanPlayerUnfreeze", "PropSecure_UnFreeze",function(ply, ent, phys)
	if (ent:GetClass() != "prop_physics") then return end

	local min = ent:LocalToWorld(ent:OBBMins());
	local max = ent:LocalToWorld(ent:OBBMaxs());
	local foundEnts = ents.FindInBox(min, max);

	for k,v in ipairs(foundEnts) do
		if v.IsWorld and v:IsWorld() then 
			if ent.GetPhysicsObject and IsValid(ent:GetPhysicsObject()) then
				ent:GetPhysicsObject():EnableMotion(false)
			end
			freezeReal(ent)
			continue 
		end

		if (v != ent) and v:GetClass() == "prop_physics" then
			return false
		end
	end
end)

timer.Create("PropSecure_Checker", 5, 0, function()
	for v,ent in pairs(ents.FindByClass("prop_physics")) do
		if !IsValid(ent) then continue end
		
		if !isfunction(ent.GetPhysicsObject) or !IsValid(ent:GetPhysicsObject()) or !ent:GetPhysicsObject():IsMotionEnabled() then continue end

		local min = ent:LocalToWorld(ent:OBBMins());
		local max = ent:LocalToWorld(ent:OBBMaxs());
		local foundEnts = ents.FindInBox(min, max);

		if #foundEnts < 2 then return end

		for k,v in ipairs(foundEnts) do
			if (v != ent) and v:GetClass() == "prop_physics" then
				if not ent:GetPhysicsObject():IsMotionEnabled() then
					continue
				end

				v:GetPhysicsObject():AddGameFlag(FVPHYSICS_CONSTRAINT_STATIC)
				continue
			end
		end
	end
end)

hook.Add("EntityTakeDamage", "PropSecure_AntiDamage", function(ply, dmg)
	local ent = dmg:GetInflictor()

	if !ply.IsPlayer or !ply:IsPlayer() then return end

	if dmg:GetDamageType() == DMG_CRUSH or (IsValid(ent) and ent:GetClass() == "prop_physics") then
		dmg:SetDamageForce(Vector(0, 0, 0))
		dmg:SetDamage(0)
	end

	if !IsValid(ent) then return end

	if ent:IsVehicle() then
		dmg:ScaleDamage(0.3)
		return
	end

	local phys = ent:GetPhysicsObject()
	if ply:InVehicle() then return end
	if (ent:GetClass() != "prop_physics") then return; end
	if !IsValid(phys) or !phys:IsMotionEnabled() then return end

	ent:SetVelocity(Vector(0, 0, 0))
	ent.oldColor = ent:GetColor();
	ent.oldMat = ent:GetMaterial();
	
	ent:SetColor(Color(ent.oldColor.r, ent.oldColor.g, ent.oldColor.b, 100))
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD);
	dmg:SetDamage(0)
end)
hook.Remove("ScalePlayerDamage", "PropSecure_AntiDamage")

hook.Add("GravGunPunt", "PropSecure_Punt", function(ply, ent)
	if IsValid(ent) and ent:IsVehicle() then
		return false
	end
end)
