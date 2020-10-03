/// @description  object_get_index(name)
/// @param name string
function object_get_index(argument0) {

	var name = argument0;
	var value = ds_map_find_value(global._object_mapping, name);
	if (!is_undefined(value))
	{
		return value;
	}
	else
	{
		for (var i = 0; i < 9999; ++i)
		{
			if (object_exists(i)) 
			{
				if (object_get_name(i) == name)
				{
					ds_map_add(global._object_mapping, name, i);
					return i;
				}
			}
		}
	}

	return null;


}
