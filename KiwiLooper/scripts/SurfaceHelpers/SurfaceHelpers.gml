///@function surface_clear_color_alpha(surface, color, alpha)
function surface_clear_color_alpha(surface, color, alpha)
{
	surface_set_target(surface);
	draw_clear_alpha(color, alpha);
	surface_reset_target();
}
