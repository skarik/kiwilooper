function collision4_move_contact_meeting(xdir, ydir)
{
	var sqrDistance = sqr(xdir) + sqr(ydir);
	if (sqrDistance < KINDA_SMALL_NUMBER)
	{
		return other;
	}
	
	var length = sqrt(sqrDistance);
	var xdir_n = xdir / length;
	var ydir_n = ydir / length;
	
	var kStepDistance = 0.5;

	for (var i = 0.0; i < clamp(length, kStepDistance * 4, 1024); i += kStepDistance)
	{
		var next_x = x + xdir_n * kStepDistance;
		var next_y = y + ydir_n * kStepDistance;
		
		if (!collision4_meeting(next_x, next_y, z))
		{
			x = next_x;
			y = next_y;
		}
		else
		{
			break;	
		}
	}

	return other;
}