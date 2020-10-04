/// @description Set up AI shenanigans

// Inherit the parent event
event_inherited();

airoboCreate();

// Set up animation
kAnimStand = spr_roboStand;
kAnimAttack = spr_roboAttackEmpty;

// Set up helpers
m_weapon = inew(o_fxKiwiWrench);
m_weapon.visible = false;
m_weapon.sprite_index = spr_roboAttackAttachment;

// Set up callbacks
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