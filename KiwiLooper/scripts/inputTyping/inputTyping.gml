/// @function inputPollTyping(value, cursor)
/// @desc Emulates out-of-order typing via excessive keyboard polling.
/// @returns Edited string.
function inputPollTyping(value, cursor)
{
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