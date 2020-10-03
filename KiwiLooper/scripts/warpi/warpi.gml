function warpi(argument0, argument1, argument2)
{
	var value = argument0;
	var minimum = argument1;
	var maximum = argument2;

	// Swap min and max if their values are invalid
	if (minimum > maximum) {
		var temp = maximum;
		maximum = minimum;
		minimum = temp;
	}

	// Move the wrap distance around
	var delta = maximum - minimum;

	// Make sure the value is large enough
	while (value < minimum)
	{
		value += delta;
	}
	// Make sure the value is small enough
	while (value >= maximum)
	{
		value -= delta;
	}

	return value;
	// TODO: There is a faster way to do this.
}
