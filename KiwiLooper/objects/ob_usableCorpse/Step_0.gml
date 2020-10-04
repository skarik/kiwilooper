/// @description Update motion

if (!m_pickedUp)
{
	// Do common z motion
	mvtcZMotion();
	
	// Do common x-y collision
	mvtcCollision();
	
	// Stop motion if on ground
	if (onGround)
	{
		xspeed = sign(xspeed) * max(0.0, abs(xspeed) - 500 * Time.deltaTime);
		yspeed = sign(yspeed) * max(0.0, abs(yspeed) - 500 * Time.deltaTime);
	}
	
	// Apply motion
	x += xspeed * Time.deltaTime;
	y += yspeed * Time.deltaTime;
	
	if (!onGround)
	{
		// Check if we hit any character
		var collided_enemy = collision_circle(x, y, 8, ob_character, false, true);
		if (iexists(collided_enemy))
		{
			damageTarget(m_pickedUpBy, collided_enemy, 1, kDamageTypeBlunt, x, y);
		}
	}
}
else
{
	// Disable collision when on air. This can be done by marking not on ground
	onGround = false;
	
	if (iexists(m_pickedUpBy))
	{
		// Move to nearby player w/ a slide angle to prevent zfighting
		x = m_pickedUpBy.x + lengthdir_x(8, m_pickedUpBy.facingDirection + 5);
		y = m_pickedUpBy.y + lengthdir_y(8, m_pickedUpBy.facingDirection + 5);
		z = m_pickedUpBy.z + 4;
	
		// Update the mesh since we're being dragged around
		m_updateMesh();
	}
	else
	{
		m_pickedUp = false;
	}
}