/// @func array_contains(array, value)
/// @param array {Array 1d}
/// @param value
function array_contains(argument0, argument1) {

	var array = argument0;
	var value = argument1;
	var len = array_length_1d(array);
	for (var i = 0; i < len; ++i)
	{
		if (array[i] == value)
		{
			return true;
		}
	}

	return false;


}
