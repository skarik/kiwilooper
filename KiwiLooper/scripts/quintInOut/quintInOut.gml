function quintInOut(argument0) {
	var t = argument0;
	if (t < 0.5)
	{
		var t2 = t * t;
		return 16.0 * t * t2 * t2;
	}
	else
	{
		var f = ((2 * t) - 2);
		return 0.5 * f * f * f * f * f + 1.0;
	}


}
