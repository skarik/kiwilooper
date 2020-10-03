function controlAnyKey() {
	// TODO

	if (keyboard_check(vk_anykey) || mouse_check_button(mb_any)
		|| gamepad_button_check(0, gp_start) || gamepad_button_check(0, gp_face1) || gamepad_button_check(0, gp_face2))
	{
		return true;
	}
	return false;


}
