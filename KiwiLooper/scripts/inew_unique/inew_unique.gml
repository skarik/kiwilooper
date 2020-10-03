/// @function inew(object_index)
function inew_unique(argument0) {
	if (!iexists(argument0))
	{
		return instance_create_depth(0, 0, 0, argument0);
	}
	return null;


}
