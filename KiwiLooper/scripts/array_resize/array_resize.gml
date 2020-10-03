///@function array_resize(array, length)
///@param array
///@param length
function array_resize(argument0, argument1) {

	var array = argument0;
	var length = argument1;
	var current_length = array_length_1d(array);

	if (length != current_length)
	{
		var new_array = array_create(length);
		array_copy(new_array, 0, array, 0, min(length, current_length));
		return new_array;
	}

	return array;


}
