function bounceOut(argument0) {
	var t = argument0;

	return 1.0 - power(2.0, -6.0 * t) * abs(cos(t * pi * 3.5));


}
