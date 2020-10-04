/// @description Set up AI shenanigans

// Inherit the parent event
event_inherited();

airoboCreate();

// Set up motion changes
attackState = mvtRoboAttack;
kMoveSpeed = 70; // Robo should be faster than player

// Set up animation
kAnimStand = spr_roboStand;
kAnimAttack = spr_roboAttackEmpty;

// Set up helpers
m_weapon = inew(o_fxKiwiWrench);
m_weapon.visible = false;
m_weapon.sprite_index = spr_roboAttackAttachment;

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
	
	// Update sprite based on damage
	if (lastDamageType == kDamageTypeShock)
	{
		sound_play_at(x, y, z, "sound/element/shock_death_short.wav");
	}
}
m_onDeath = function()
{
	// Spawn a robot corpse...
	var corpse = inew(o_usableCorpseRobo);
		corpse.x = x;
		corpse.y = y;
		corpse.z = z;
		corpse.image_angle = facingDirection + 180;
		corpse.m_updateMesh();
	
	// Remove self
	instance_destroy();
}