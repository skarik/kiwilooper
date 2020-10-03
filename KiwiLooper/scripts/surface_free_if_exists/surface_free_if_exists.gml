/// @function surface_free_if_exists(surface)
/// @param surface {Surface}
function surface_free_if_exists(argument0) {

	var surface = argument0;
	if (surface_exists(surface))
	{
		surface_free(surface);
		return true;
	}
	return false;


}
