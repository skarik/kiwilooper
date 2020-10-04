/// @description Set up everything

// Inherit the parent event
event_inherited();

PlayerControl_Create();

// Set up animation
kAnimStand = spr_kiwiStand;
kAnimAttack = spr_kiwiAttackEmpty;

// Set up helpers
m_wrench = inew(o_fxKiwiWrench);
m_wrench.visible = false;

// Set up callbacks
m_onBeginDeath = function()
{
	// Create blood here
	repeat (2)
	{
		var blood = inew(o_playerSplatter);
			blood.x = x + random_range(-8, +8);
			blood.y = y + random_range(-8, +8);
			blood.z = z;
			blood.image_xscale = choose(-1, 1);
			blood.image_yscale = choose(-1, 1);
			blood.image_angle = choose(0, 90, 180, 270);
			blood.image_index = floor(random(blood.image_number));
	}
}
m_onDeath = function()
{
	// Spawn a corpse...
	
	// Restart the room. Pretty straightforward - we just loop
	room_restart();
}