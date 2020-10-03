/// @description  audio_get_index(name)
/// @param name string
function audio_get_index(argument0) {

	var name = argument0;
	var value = ds_map_find_value(global._audio_mapping, name);
	if (!is_undefined(value))
	{
		return value;
	}
	else
	{
		for (var i = 0; i < 9999; ++i)
		{
			if (audio_exists(i)) 
			{
				if (audio_get_name(i) == name)
				{
					ds_map_add(global._audio_mapping, name, i);
					return i;
				}
			}
		}
	}

	return null;


}
