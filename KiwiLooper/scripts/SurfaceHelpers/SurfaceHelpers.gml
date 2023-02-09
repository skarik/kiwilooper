///@function surface_create_from_surface_params(surface_for_params)
///@param surface_for_params {Surface}
function surface_create_from_surface_params(surface_for_params)
{
	gml_pragma("forceinline");
	return surface_create(surface_get_width(surface_for_params), surface_get_height(surface_for_params));
}

/// @function surface_free_if_exists(surface)
/// @param surface {Surface}
function surface_free_if_exists(surface)
{
	gml_pragma("forceinline");
	if (surface_exists(surface))
	{
		surface_free(surface);
		return true;
	}
	return false;
}

///@function surface_clear_color_alpha(surface, color, alpha)
function surface_clear_color_alpha(surface, color, alpha)
{
	gml_pragma("forceinline");
	surface_set_target(surface);
	draw_clear_alpha(color, alpha);
	surface_reset_target();
}