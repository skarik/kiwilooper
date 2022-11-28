function mvtcCollision()
{
	// Reset wall check state
	motionHitWall = false;

	// Do X collision
	if (abs(xspeed) > 0.0)
	{
		if (collision4_meeting(x + xspeed * Time.deltaTime, y, z))
		{
			// Move into contact
			collision4_move_contact_meeting(sign(xspeed), 0);
			// Stop motion
			xspeed = 0;
			// Mark we hit a wall
			motionHitWall = true;
		}
	}
	
	// Do Y collision
	if (abs(yspeed) > 0.0)
	{
		if (collision4_meeting(x, y + yspeed * Time.deltaTime, z))
		{
			// Move into contact
			collision4_move_contact_meeting(0, sign(yspeed));
			// Stop motion
			yspeed = 0;
			// Mark we hit a wall
			motionHitWall = true;
		}
	}
}

function mvtcZMotion()
{
	//var highest_z = collision4_get_highest(x, y, z);
	// instead, raycast down
	var highest_z = z;
	if (collision4_rectanglecast2(new Vector3(x, y, z + 16), sprite_get_width(mask_index), sprite_get_height(mask_index), new Vector3(0, 0, -1), kHitmaskAll))
	{
		highest_z = (z + 16) - raycast4_get_hit_distance();
	}
	
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