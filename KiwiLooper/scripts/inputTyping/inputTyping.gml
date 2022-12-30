/// @function inputPollTyping(value, cursor)
/// @desc Emulates out-of-order typing via excessive keyboard polling.
/// @returns Edited string.
function inputPollTyping(value, cursor)
{
	// Move the edit cursor
	if (cursor == null)
	{
		cursor = string_length(value);
	}
	if (keyboard_check_pressed(vk_left)
		|| (!keyboard_get_numlock() && keyboard_check_pressed(vk_numpad4)))
	{
		cursor = max(0, cursor - 1);
	}
	else if (keyboard_check_pressed(vk_right)
		|| (!keyboard_get_numlock() && keyboard_check_pressed(vk_numpad6)))
	{
		cursor = min(string_length(value), cursor + 1);
	}
	else if (keyboard_check_pressed(vk_home)
		|| (!keyboard_get_numlock() && keyboard_check_pressed(vk_numpad7)))
	{
		cursor = 0;
	}
	else if (keyboard_check_pressed(vk_end)
		|| (!keyboard_get_numlock() && keyboard_check_pressed(vk_numpad1)))
	{
		cursor = string_length(value);
	}
	
	// Check letters
	for (var key = ord("A"); key <= ord("Z"); ++key)
	{
		if (keyboard_check_pressed(key)) {
			if (keyboard_check(vk_shift)) {
				value = string_insert(chr(key), value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert(chr(key - ord("A") + ord("a")), value, cursor + 1);
				cursor++;
			}
		}
	}
	// Check numbers
	for (var key = ord("0"); key <= ord("9"); ++key)
	{
		if (keyboard_check_pressed(key)) {
			value = string_insert(chr(key), value, cursor + 1);
			cursor++;
		}
	}
	// Check numpad
	if (keyboard_get_numlock())
	{
		for (var key = vk_numpad0; key <= vk_numpad9; ++key)
		{
			if (keyboard_check_pressed(key)) {
				value = string_insert(chr(ord("0") + key - vk_numpad0), value, cursor + 1);
				cursor++;
			}
		}
	}
	else
	{
		// TODO: arrow keys
	}
	// Check symbols
	{
		if (keyboard_check_pressed(0xBD))
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("_", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("-", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xBC))
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("<", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert(",", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xBE))
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert(">", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert(".", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xBF)) //VK_OEM_2
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("?", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("/", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xC0)) //VK_OEM_3
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("~", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("`", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xDB)) //VK_OEM_4
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("{", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("[", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xDC)) //VK_OEM_5
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("|", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("\\", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xDD)) //VK_OEM_6
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("}", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("]", value, cursor + 1);
				cursor++;
			}
		}
		if (keyboard_check_pressed(0xDE)) //VK_OEM_7
		{
			if (keyboard_check(vk_shift)) {
				value = string_insert("\"", value, cursor + 1);
				cursor++;
			}
			else {
				value = string_insert("'", value, cursor + 1);
				cursor++;
			}
		}
	}
	// Check space
	if (keyboard_check_pressed(vk_space)) {
		value = string_insert(" ", value, cursor + 1);
		cursor++;
	}
	
	// Delete character:
	if (keyboard_check_pressed(vk_backspace))
	{
		if (string_length(value) > 0 && cursor > 0)
		{
			if (cursor < string_length(value)) {
				value = string_copy(value, 1, cursor - 1) + string_copy(value, cursor + 1, string_length(value) - cursor);
				cursor--;
			}
			else {
				value = string_copy(value, 1, cursor - 1);
				cursor--;
			}
		}
	}
	if (keyboard_check_pressed(vk_delete))
	{
		if (string_length(value) > 0 && cursor < string_length(value))
		{
			if (cursor > 0) {
				value = string_copy(value, 1, cursor) + string_copy(value, cursor + 2, string_length(value) - cursor - 1);
			}
			else {
				value = string_copy(value, cursor + 2, string_length(value) - cursor - 1);
			}
		}
	}
	
	return {value: value, cursor: cursor};
}