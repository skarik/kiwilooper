/// @description  object_register_name(index)
/// @param index
function object_register_name(argument0) {

	var index = argument0;
	ds_map_add(global._object_mapping, object_get_name(index), index);


}
