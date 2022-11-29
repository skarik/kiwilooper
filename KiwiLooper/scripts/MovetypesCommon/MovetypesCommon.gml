function mvtcCollision()
{
	// Reset wall check state
	motionHitWall = false;

	// Do X collision
	/*if (abs(xspeed) > 0.0)
	{
		// TODO: replace collision4_meeting with a shapecast
		
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
		// TODO: replace collision4_meeting with a shapecast
		
		if (collision4_meeting(x, y + yspeed * Time.deltaTime, z))
		{
			// Move into contact
			collision4_move_contact_meeting(0, sign(yspeed));
			// Stop motion
			yspeed = 0;
			// Mark we hit a wall
			motionHitWall = true;
		}
	}*/
	
	// Create a vector of our speed
	var mspeed = new Vector3(xspeed, yspeed, 0);
	var mspeed_len = mspeed.magnitude();
	if (mspeed_len > 0.0)
	{
		var kBoxHeight = 10;
		var bbox = new BBox3(
			new Vector3(x, y, z + kBoxHeight * 0.5),
			new Vector3(sprite_get_width(mask_index) * 0.5, sprite_get_height(mask_index) * 0.5, kBoxHeight * 0.5)
			);
		
		// Do combined XY collision
		if (collision4_bbox2cast(bbox, mspeed.divide(mspeed_len), mspeed_len * Time.deltaTime, kHitmaskAll))
		{
			// Is the hit we're recording actually in-range?
			if (raycast4_get_hit_distance() < mspeed_len * Time.deltaTime)
			{
				// Move into contact
				mspeed.divideSelf(mspeed_len).multiplySelf(raycast4_get_hit_distance());
				
				// Mark we hit a wall
				motionHitWall = true;
			}
		}
	}
	
	// Write the separated speeds back out.
	xspeed = mspeed.x;
	yspeed = mspeed.y;
	
	/*
		var kBoxHeight = 10;
		var bbox = new BBox3(new Vector3(x, y, z + kBoxHeight * 0.5), new Vector3(sprite_get_width(mask_index) * 0.5, sprite_get_height(mask_index) * 0.5, kBoxHeight * 0.5));
		
		bbox.center.y = y + yspeed * Time.deltaTime;
		if (collision4_bbox2(bbox, kHitmaskAll))
		*/
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