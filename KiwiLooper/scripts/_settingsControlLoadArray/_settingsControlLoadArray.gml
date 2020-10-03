function _settingsControlLoadArray(argument0, argument1) {
	var kGbButtonMapping = [
		"face1", gp_face1,
		"face2", gp_face2,
		"face3", gp_face3,
		"face4", gp_face4,
		"lbutton", gp_shoulderl,
		"ltrigger", gp_shoulderlb,
		"rbutton", gp_shoulderr,
		"rtrigger", gp_shoulderrb,
		"select", gp_select,
		"start", gp_start,
		"lstick", gp_stickl,
		"rstick", gp_stickr,
		"dup", gp_padu,
		"ddown", gp_padd,
		"dleft", gp_padl,
		"dright", gp_padr,
		"laxisx", gp_axislh,
		"laxisy", gp_axislv,
		"raxisx", gp_axisrh,
		"raxisy", gp_axisrv,
	];


	var control_name = argument0;
	var control_default = argument1;

	// Load the control from the listing
	var control_string = ini_read_string("controls", control_name, "INVALID");
	if (control_string == "INVALID")
	{
		return control_default;
	}

	// Fix the whitespace so people can use tabs
	control_string = string_fix_whitespace(control_string);
	// Make it all lowercase for easier parsing
	control_string = string_lower(control_string);

	// Parse out the control string via spaces
	var control_tokens = string_split(control_string, " ", true);
	var control_token_count = array_length_1d(control_tokens);

	// Ensure the string length is correct
	if (control_token_count % 2 != 0)
	{
		return control_default;
	}

	// Set up control now
	var control_read = array_create(0);
	// Actually parse now
	for (var i = 0; i < control_token_count; i += 2)
	{
		var key = control_tokens[i];
		var value = control_tokens[i + 1];
	
		if (key == "kb")
		{
			control_read[array_length_1d(control_read)] = kControlKB;
			control_read[array_length_1d(control_read)] = real(value);
		}
		else if (key == "mouse")
		{
			control_read[array_length_1d(control_read)] = kControlMouse;
			if (value == "left")
				control_read[array_length_1d(control_read)] = mb_left;
			else if (value == "right")
				control_read[array_length_1d(control_read)] = mb_right;
			else if (value == "middle")
				control_read[array_length_1d(control_read)] = mb_middle;
			else if (value == "wheelup")
				control_read[array_length_1d(control_read)] = kMouseWheelUp;
			else if (value == "wheeldown")
				control_read[array_length_1d(control_read)] = kMouseWheelDown;
			else
				control_read[array_length_1d(control_read)] = null;
		}
		else if (key == "gamepad")
		{	
			// parse out a + or - from the front
			var flip = false;
			var first = string_char_at(value, 1);
			if (first == "+" || first == "-")
			{
				value = string_copy(value, 2, string_length(value) - 1);
				if (first == "-")
					flip = true;
			}
		
			// select the right value from mapping
			control_read[array_length_1d(control_read)] = kControlGamepad;
			var read_good = false;
			for (var imap = 0; imap < array_length_1d(kGbButtonMapping); imap += 2)
			{
				if (value == kGbButtonMapping[imap])
				{	// Read in the control mapping if correct
					control_read[array_length_1d(control_read)] = flip ? (-kGbButtonMapping[imap + 1]) : kGbButtonMapping[imap + 1];
					read_good = true;
					break;
				}
			}
			if (!read_good)
			{	// Fill in invalid values
				control_read[array_length_1d(control_read)] = null;
			}
		}
	}

	return control_read;


}
