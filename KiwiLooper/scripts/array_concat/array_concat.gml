/// @function array_concat(array0, array1)
/// @param array0
/// @param array1
function array_concat(argument0, argument1) {

	var array0 = argument0;
	var array1 = argument1;
	var result = array_create(0);
	var len0 = array_length_1d(array0);
	array_copy(result, 0, array0, 0, len0);
	array_copy(result, len0, array1, 0, array_length_1d(array1));
	return result;


}
