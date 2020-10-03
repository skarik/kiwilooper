
function mvtNormal()
{
	var inputAxis = new Vector2(xAxis.value, yAxis.value);
	// If the player, we need to rotate the motion to match the view
	if (isPlayer && iexists(o_Camera3D))
	{
		inputAxis.rotateSelf(o_Camera3D.zrotation - 90);
	}
	
	// Update speed
	xspeed = inputAxis.x * kMoveSpeed;
	yspeed = inputAxis.y * kMoveSpeed;
	
	// Limit max speed
	var total_speed_sqr = sqr(xspeed) + sqr(yspeed);
	if (total_speed_sqr > sqr(kMoveSpeed))
	{
		var total_speed = sqrt(total_speed_sqr);
		xspeed *= kMoveSpeed / total_speed;
		yspeed *= kMoveSpeed / total_speed;
	}
	
	// Update facing direction
	if (total_speed_sqr > 1)
	{
		facingDirection = point_direction(0, 0, xspeed, yspeed);
	}
	
	// Do the actual motion
	x += xspeed * Time.deltaTime;
	y += yspeed * Time.deltaTime;
	
	return mvtNormal;
}