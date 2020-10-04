/// @description Update animation & attachments

event_inherited();

if (sprite_index == kAnimAttack)
{
	m_weapon.visible = true;
	m_weapon.x = x;
	m_weapon.y = y;
	m_weapon.z = z + 8;
	m_weapon.image_index = animationRenderIndex % 3;
	m_weapon.zrotation = facingDirection + 90;
	m_weapon.m_updateMesh();
}
else
{
	m_weapon.visible = false;
}