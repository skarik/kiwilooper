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