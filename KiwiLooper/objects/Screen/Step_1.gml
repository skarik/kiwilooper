/// @description Limit mouse

if (limitMouseMode == kLimitMouseMode_Clamp)
{
	window_mouse_set(
		clamp(window_mouse_get_x(), 0, width),
		clamp(window_mouse_get_y(), 0, height)
		);
}
else if (limitMouseMode == kLimitMouseMode_Wrap)
{
	var wmouse_x = window_mouse_get_x();
	var wmouse_y = window_mouse_get_y();
	var offset_x = 0;
	var offset_y = 0;
	
	if (wmouse_x < 0)
	{
		offset_x += width;
	}
	else if (wmouse_x > width)
	{
		offset_x -= width;
	}
	if (wmouse_y < 0)
	{
		offset_y += height;
	}
	else if (wmouse_y > height)
	{
		offset_y -= height;
	}
	
	if (offset_x != 0 || offset_y != 0)
	{
		limitMouseWrapCallbacks.Call(offset_x, offset_y);
		window_mouse_set(wmouse_x + offset_x, wmouse_y + offset_y);
	}
}

