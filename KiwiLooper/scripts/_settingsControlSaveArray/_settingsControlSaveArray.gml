function _settingsControlSaveArray(argument0, argument1) {
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
	var control_value = argument1;

	// Load the control from the listing
	var control_string = "";

	// Actually make string now
	var control_count = array_length_1d(control_value);
	for (var i = 0; i < control_count; i += 2)
	{
		var context = control_value[i];
		var input = control_value[i + 1];
	
		if (context == kControlKB)
		{
			control_string += "kb";
			control_string += " ";
		
			control_string += string(input);
			control_string += " ";
		}
		else if (context == kControlMouse)
		{
			control_string += "mouse";
			control_string += " ";
		
			if (input == mb_left)
				control_string += "left";
			else if (input == mb_right)
				control_string += "right";
			else if (input == mb_middle)
				control_string += "middle";
			else if (input == kMouseWheelUp)
				control_string += "wheelup";
			else if (input == kMouseWheelDown)
				control_string += "wheeldown";
			else
				control_string += "?";
			control_string += " ";
		}
		else if (context == kControlGamepad)
		{	
			control_string += "gamepad";
			control_string += " ";
		
			var read_good = false;
			for (var imap = 0; imap < array_length_1d(kGbButtonMapping); imap += 2)
			{
				if (abs(input) == kGbButtonMapping[imap + 1])
				{	// Add the directionality of the input
					if (input < 0)
						control_string += "-";
					else
						control_string += "+";
					// Add the mapping
					control_string += kGbButtonMapping[imap];
					read_good = true;
					break;
				}
			}
			if (!read_good)
			{	// If a bad mapping, add a ??
				control_string += "?";
			}
			control_string += " ";
		}
	}

	// Write ini output
	ini_write_string("controls", control_name, control_string);

	return control_value;


}
