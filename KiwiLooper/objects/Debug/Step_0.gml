// Is tilde pressed?
if ( keyboard_check_pressed(192) )
{
    // Toggle the menu when it is pressed down:
	if (!on)
	{
		Show();
	}
	else
	{
		Hide();
	}
}

// Debug toggles for the palette swatcher.
if ( keyboard_check(vk_control) && keyboard_check_pressed(ord("8")) )
{
	paletteSetCurrent(kPaletteCrushed);
}
if ( keyboard_check(vk_control) && keyboard_check_pressed(ord("9")) )
{
	paletteSetCurrent(kPaletteWide);
}