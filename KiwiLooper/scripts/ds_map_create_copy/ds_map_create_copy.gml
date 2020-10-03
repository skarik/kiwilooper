///@function ds_map_create_copy(map)
///@param map
function ds_map_create_copy(argument0) {

	var map = argument0;
	var result = ds_map_create();
	ds_map_copy(result, map);
	return result;


}
