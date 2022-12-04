function controlAnyKey()
{
	// TODO

	if (keyboard_check_pressed(vk_anykey) || mouse_check_button_pressed(mb_any)
		|| gamepad_button_check_pressed(0, gp_start) || gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(0, gp_face2))
	{
		return true;
	}
	return false;
}
