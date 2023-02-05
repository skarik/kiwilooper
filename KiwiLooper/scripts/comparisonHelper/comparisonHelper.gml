/// @function is_equal(a, b)
function is_equal(a, b)
{
	gml_pragma("forceinline");
	
	var a_def = !is_undefined(a);
	var b_def = !is_undefined(b);
	if (a_def && b_def)
		return a == b;
	else
		return a_def == b_def;
}