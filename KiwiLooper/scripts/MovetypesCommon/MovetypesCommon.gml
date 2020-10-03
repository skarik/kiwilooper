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