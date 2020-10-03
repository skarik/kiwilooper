function expoInOut(argument0) {
	var t = argument0;
	if (t < 0.5)
	{
		return (power(2.0, 16.0 * t) - 1) / 510.0;
	}
	else
	{
		return 1.0 - 0.5 * power(2, -16.0 * (t - 0.5));
	}


}
