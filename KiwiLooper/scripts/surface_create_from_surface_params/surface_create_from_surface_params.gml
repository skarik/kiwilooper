///@function surface_create_from_surface_params(surface_for_params)
///@param surface_for_params {Surface}
function surface_create_from_surface_params(argument0) {

	var surface_for_params = argument0;
	return surface_create(surface_get_width(surface_for_params), surface_get_height(surface_for_params));


}
