/// @description  script_register_name(index)
/// @param index
function script_register_name(argument0)
{
	var index = argument0;
	ds_map_add(global._script_mapping, script_get_name(index), index);
}
