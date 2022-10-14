/// @description Set up everything

// Inherit the parent event
event_inherited();

PlayerControl_Create();

// Set up animation
kAnimStand = spr_kiwiStand;
kAnimAttack = spr_kiwiAttackEmpty;
kAnimWalk = spr_kiwiWalk;

// Set up helpers
m_wrench = inew(o_fxKiwiWrench);
m_wrench.visible = false;

// Set up UI
m_uiUsables = inew(o_uisPlayerUsables);
m_uiTally = inew(o_uisTallyMarks);

// Set up progression
m_inventory = {
	keys: array_create(100, 0),
};

// Set up callbacks
onPostLevelLoad = function()
{
	// Save camera start for death.
	xstart = x;
	ystart = y;
	zstart = z;
}
m_onBeginDeath = function()
{
	// Create blood here
	if (lastDamageType != kDamageTypeMagicVoid)
	{
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
	
	// No longer visible
	visible = false;
	
	// Spawn a corpse...
	var corpse = inew(o_usableCorpseKiwi);
		corpse.x = x;
		corpse.y = y;
		corpse.z = z;
		corpse.image_angle = facingDirection;
		corpse.m_updateMesh();
		
	// Abberate screen
	effectAbberate(0.01, 0.2, true);
		
	// Update sprite based on damage
	if (lastDamageType == kDamageTypeShock)
	{
		kAnimDeath = spr_kiwiShock;
		corpse.visible = false;
		visible = true;
		
		sound_play_at(x, y, z, "sound/element/shock_death.wav");
		
		var spark = inew(o_envFxSpark);
			spark.x = x;
			spark.y = y;
			spark.z = z + 8;
	}
	else if (lastDamageType == kDamageTypeMagicVoid)
	{
		// No corpse if we fall down to our death
		idelete(corpse);
	}
	else
	{
		// Shake screen for death
		effectScreenShake(1.5, 0.4, true);
	}
	
	// Tally it up
	Gameplay.m_tallyCount += 1;
}
m_onDeath = function()
{
	// Restart the room. Pretty straightforward - we just loop
	if (room == Gameplay.m_checkpoint_room)
	{
		room_restart();
	}
	else
	{
		room_goto(Gameplay.m_checkpoint_room);
	}
}