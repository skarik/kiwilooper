/// @description Update rect & hover

rect = [0, Screen.height - 24, Screen.width, 24];
duiStepHoverFocus();
duiStepAlphaGlobal();

// Update typing
if (focused)
{
	// Check letters
	for (var key = ord("A"); key <= ord("Z"); ++key)
	{
		if (keyboard_check_pressed(key)) {
			if (keyboard_check(vk_shift)) {
				command += chr(key);
			}
			else {
				command += chr(key - ord("A") + ord("a"));
			}
		}
	}
	// Check numbers
	for (var key = ord("0"); key <= ord("9"); ++key)
	{
		if (keyboard_check_pressed(key)) {
			command += chr(key);
		}
	}
	// Check symbols
	{
		if (keyboard_check_pressed(0xBD))
		{
			if (keyboard_check(vk_shift)) {
				command += "_";
			}
			else {
				command += "-";
			}
		}
	}
	// Check space
	if (keyboard_check_pressed(vk_space)) {
		command += " ";
	}
	
	// Delete character:
	if (keyboard_check_pressed(vk_backspace))
	{
		if (string_length(command) > 0)
			command = string_copy(command, 1, string_length(command) - 1);
	}
	if (keyboard_check_pressed(vk_escape))
	{
		command = "";
	}
	
	// Is command submitted?
	if (keyboard_check_pressed(vk_enter))
	{
		debugLog(kLogOutput, "debug>" + command);
		dcmdParse(kCmdlineParserModeWork, command);
		command = "";
	}
}