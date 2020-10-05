/// @description Set up AI shenanigans

// Inherit the parent event
event_inherited();

// Disable movespeed
kMoveSpeed = 0;

// Set up callbacks
m_onBeginDeath = function()
{
	// Create blood here
	repeat (2)
	{
		var blood = inew(o_oilSplatter);
			blood.x = x + random_range(-8, +8);
			blood.y = y + random_range(-8, +8);
			blood.z = z;
			blood.image_xscale = choose(-1, 1);
			blood.image_yscale = choose(-1, 1);
			blood.image_angle = choose(0, 90, 180, 270);
			blood.image_index = floor(random(blood.image_number));
	}
	
	var explosion = inew(ob_billboardSprite);
		explosion.x = x;
		explosion.y = y;
		explosion.z = z + 16;
		explosion.sprite_index = sfx_explo5;
		explosion.killOnEnd = true;
		explosion.m_updateMesh();
	
	// Shake the screen!
	effectScreenShake(5.0, 2.0, true);
	// Abberate screen
	effectAbberate(2 / GameCamera.width, 1.1, false);
	effectAbberate(0.01, 0.6, true);
	
	// Create sound
	sound_play_at(x, y, z, "sound/element/shock_death_short.wav");
}
m_onDeath = function()
{
	// Spawn a cell corpse...
	var corpse = inew(o_doodadPowercellDeadbit);
		corpse.x = x;
		corpse.y = y;
		corpse.z = z;
		corpse.image_angle = random(360);
	
	// Remove self
	instance_destroy();
}