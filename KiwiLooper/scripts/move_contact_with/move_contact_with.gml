function move_contact_with(argument0, argument1, argument2) {
	var xdir = argument0;
	var ydir = argument1;
	var hitClass = argument2;

	var sqrDistance = sqr(xdir) + sqr(ydir);
	if (sqrDistance < 0.001)
	{
		place_meeting(x, y, hitClass);
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
		if (!place_meeting(next_x, next_y, hitClass))
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
