/// @description  audio_register_name(index)
/// @param index
function audio_register_name(argument0) {

	var index = argument0;
	ds_map_add(global._audio_mapping, audio_get_name(index), index);


}
