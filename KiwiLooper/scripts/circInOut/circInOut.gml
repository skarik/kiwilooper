function circInOut(argument0) {
	var t = argument0;

	if (t < 0.5)
	{
		return (1.0 - sqrt(max(0.0, 1.0 - 2.0 * t))) * 0.5;
	}
	else
	{
		return (1.0 + sqrt(max(0.0, 2.0 * t - 1.0))) * 0.5;
	}


}
