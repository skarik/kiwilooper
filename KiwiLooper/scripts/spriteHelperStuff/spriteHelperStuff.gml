function _sprite_find_name_preache()
{
	global._sprite_find_things_first = [
		stl_lab0,
		];
}
gml_pragma("global", "_sprite_find_name_preache()");


/// @function sprite_find_name(sprite_name)
function sprite_find_name(sprite_name)
{
	for (var i = 0; i < array_length(global._sprite_find_things_first); ++i)
	{
		var spr = global._sprite_find_things_first[i];
		if (sprite_get_name(spr) == sprite_name)
		{
			return spr;
		}
	}
	return stl_lab0; // TODO
}