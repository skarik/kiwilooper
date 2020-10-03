function duiStepHoverFocus() {
	// Update UI hover state for this object
	hovered = false;

	if (enabled)
	{
		if (iexists(o_debugMenu))
		{
			if (point_in_rectangle(o_debugMenu.uiMouseX, o_debugMenu.uiMouseY, rect[0], rect[1], rect[0] + rect[2], rect[1] + rect[3]))
			{
				hovered = true;
			}
		}

		if (mouse_check_button_pressed(mb_left))
		{
			// If this one is hovered, mark all objects as not focused
			if (hovered)
			{
				with (o_debugUiBase)
				{
					focused = false;
				}
			}
			// Mark self as focused
			focused = hovered;
			// In this manner, only one object will be focused
		}
	}


}
