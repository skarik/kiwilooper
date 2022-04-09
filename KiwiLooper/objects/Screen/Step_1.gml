/// @description Limit mouse

if (limitMouse)
{
	window_mouse_set(
		clamp(window_mouse_get_x(), 0, width),
		clamp(window_mouse_get_y(), 0, height)
		);
}

