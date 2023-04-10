/// @function round_nearest(value, divisor)
function round_nearest(value, divisor)
{
	return round(value / divisor) * divisor;
}

/// @function select(index, ...)
function select(index)
{
	gml_pragma("forceinline");
	assert(index + 1 < argument_count);
	return argument[index + 1];
}

/// @function angle_lerp(from, to, t)
function angle_lerp(from, to, t)
{
	return from + angle_difference(to, from) * t;
}

/// @function is_defined_struct(value)
function is_defined_struct(value)
{
	return !is_undefined(value) && is_struct(value);
}

/// @function is_defined_array(value)
function is_defined_array(value)
{
	return !is_undefined(value) && is_array(value);
}