/// @description Click behavior

// Inherit the parent event
duiStepHoverFocus();
duiStepAlphaGlobal();

if (focused)
{
	if (mouse_check_button_pressed(mb_left))
	{
		event_user(0);
	}
}