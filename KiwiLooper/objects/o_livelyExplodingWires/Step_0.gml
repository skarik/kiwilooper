/// @description Update for explosion & actual logic

if (explosionDelay > 0.0)
{
	explosionDelay -= Time.deltaTime;
	if (explosionDelay <= 0.0)
	{
		var spawn_offset = (new Vector3(0, 0, 1)).transformAMatrixSelf(matrix_build_rotation(self));
		var explosion = inew(ob_billboardSprite);
			explosion.x = x + spawn_offset.x * 7;
			explosion.y = y + spawn_offset.y * 7;
			explosion.z = z + spawn_offset.z * 7;
			explosion.sprite_index = sfx_explo5;
			explosion.killOnEnd = true;
			explosion.m_updateMesh();
			
		// Shake screen
		effectScreenShake(4, 1.6, true);
		
		// Play 3D explosion sound here
		var sfx = sound_play_at(x, y, z, "sound/phys/explo_7.wav");
			sfx.gain = 0.2;
		
		// Vaporize nearby corpses
		var nearby_corpses = ds_list_create();
		var nearby_corpses_count = collision_circle_list(x, y, 24, ob_usableCorpse, false, true, nearby_corpses, false);
		for (var i = 0; i < nearby_corpses_count; ++i)
		{
			var corpse = nearby_corpses[|i];
			corpse.m_onVaporize(id);
		}
		ds_list_destroy(nearby_corpses);
	}
}

// Check if a body is nearby
var bDoorExists = iexists(m_targetDoor);
var door_wants_open = false;
{
	var connecting_corpse = collision_rectangle(x - 3, y - 3, x + 3, y + 3, ob_usableCorpse, false, true);
	if (iexists(connecting_corpse))
	{
		conducting = true;
		
		// Update door trigger
		door_wants_open = true;
		if (bDoorExists && !m_targetDoor.opening && m_targetDoor.openstate < 0.5)
		{
			m_targetDoor.m_onActivation(id);
		}
		
		// Track conductor to see if we should be electrifying them.
		UpdateConductor(connecting_corpse);
	}
	// no conductor? track effects
	else
	{
		conducting = false;
		
		// Clear conduction tracking
		ClearConductor();
	}
	
	// If door shouldnt be open, we must close it
	if (!door_wants_open)
	{
		if (bDoorExists && !m_targetDoor.closing && m_targetDoor.openstate > 0.5)
		{
			m_targetDoor.m_onActivation(id);
		}
	}
}
if (!bDoorExists)
{
	// Create error text for debugging for now 
	// for LD40 - we almost always want the exploding wires to have a target.
	// for other puzzles, we might not want this, so this is also wrapped within a debug mode variable
	if (Debug.lively_show_explode_wire_target)
	{
		if (!variable_instance_exists(this, "_debug_text"))
		{
			_debug_text = Debug_CreateWorldRenderText(x, y, z, "no target", c_red);
		}
	}
}
