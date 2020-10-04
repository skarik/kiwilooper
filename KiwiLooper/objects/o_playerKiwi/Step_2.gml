/// @description Update animation & attachments

event_inherited();

// Show the wrench when performing attacks
if (sprite_index == kAnimAttack)
{
	m_wrench.visible = true;
	m_wrench.x = x;
	m_wrench.y = y;
	m_wrench.z = z + 8;
	m_wrench.image_index = animationRenderIndex % 3;
	m_wrench.zrotation = facingDirection + 90;
	m_wrench.m_updateMesh();
}
else
{
	m_wrench.visible = false;
}

// Show the corpse on shock death after time
if (isDead && deathTimer > 0.4)
{
	visible = false;
	with (instance_nearest(x, y, o_usableCorpseKiwi))
	{
		visible = true;
	}
}