/// @description Update for explosion & actual logic

if (explosionDelay > 0.0)
{
	explosionDelay -= Time.deltaTime;
	if (explosionDelay <= 0.0)
	{
		var explosion = inew(ob_billboardSprite);
			explosion.x = x;
			explosion.y = y;
			explosion.z = z + 16;
			explosion.sprite_index = sfx_explo5;
			explosion.killOnEnd = true;
			explosion.m_updateMesh();
			
		// TODO: Shake screen
		
		// TODO: Play 3D explosion sound here
		
		// Vaporize nearby corpses
		var nearby_corpses = ds_list_create();
		var nearby_corpses_count = collision_circle_list(x, y, 48, ob_usableCorpse, false, true, nearby_corpses, false);
		for (var i = 0; i < nearby_corpses_count; ++i)
		{
			var corpse = nearby_corpses[|i];
			corpse.m_onVaporize(id);
		}
		ds_list_destroy(nearby_corpses);
	}
}

// Kill the characterif they step on it
var colliding_character = collision_rectangle(x - 4, y - 4, x + 4, y + 4, ob_character, false, true);
if (iexists(colliding_character))
{
	damageTarget(noone, colliding_character, 1, kDamageTypeShock, x, y);
}

// Check if a body is nearby
var door_wants_open = false;
if (iexists(m_targetDoor))
{
	var connecting_corpse = collision_rectangle(x - 3, y - 3, x + 3, y + 3, ob_usableCorpse, false, true);
	if (iexists(connecting_corpse))
	{
		door_wants_open = true;
		if (!m_targetDoor.opening && m_targetDoor.openstate < 0.5)
		{
			m_targetDoor.m_onActivation(id);
		}
	}
}
// If door shouldnt be open, we must close it
if (!door_wants_open)
{
	if (!m_targetDoor.closing && m_targetDoor.openstate > 0.5)
	{
		m_targetDoor.m_onActivation(id);
	}
}