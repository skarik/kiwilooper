/// @description Update motion

function mvtcZMotionCorpseSpecial()
{
	var highest_z = collision4_get_highest_corpseSpecial(x, y, z);
	
	// Do simple Z collision now
	if (z < highest_z)
	{
		if (highest_z - z < 8)
		{
			z = highest_z;
		}
		else
		{
			// TODO: make this push out of wall otherwise
		}
	}
	else if (z > highest_z)
	{
		onGround = false;
	}
	
	// Do falling
	if (!onGround)
	{
		zspeed -= 400 * Time.deltaTime;
	}
	
	// Do Z motion collision:
	if (z + zspeed * Time.deltaTime <= highest_z)
	{
		// Stop motion
		zspeed = 0;
		// Seek to floor
		z = highest_z;
		// Now on ground
		onGround = true;
	}
	
	// Do actual motion
	z += zspeed * Time.deltaTime;
}

if (!m_pickedUp)
{
	var wasOnGround = onGround;
	
	// Do common z motion
	mvtcZMotionCorpseSpecial();
	
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
	
	if (!onGround && (sqr(xspeed) + sqr(yspeed) > sqr(10)))
	{
		// Check if we hit any character
		var collided_enemy = collision_circle(x, y, 8, ob_character, false, true);
		if (iexists(collided_enemy))
		{
			damageTarget(m_pickedUpBy, collided_enemy, 1, kDamageTypeBlunt, x, y);
		}
	}
	
	// Shake when landing on ground & moving
	if (!wasOnGround && onGround && (sqr(xspeed) + sqr(yspeed) > sqr(10)))
	{
		effectScreenShake(1.7, 0.3, true);
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

// Update the glow outline now
UpdateGlowOutline();
