/// @function controlParseAndPoll(control)
/// @desc Polls the given input array and returns input from -1.0 to 1.0.
/// @param control {array} Input array structure
function controlParseAndPoll(argument0) {
	var control = argument0;
	var control_length = array_length_1d(control);
	var value = 0.0;

	for (var i = 0; i < control_length; i += 2)
	{
		var l_context = control[i];
		var l_input = control[i + 1];
	
		// Check keyboard (simple!)
		if (l_context == kControlKB)
		{
			value += _controlParseCheckType(keyboard_check(l_input), kControlKB);
		}
		// Check mouse control
		else if (l_context == kControlMouse)
		{
			if (l_input == kMouseWheelUp)
				value += mouse_wheel_up();
			else if (l_input == kMouseWheelDown)
				value += mouse_wheel_down();
			else 
				value += _controlParseCheckType(mouse_check_button(l_input), kControlMouse);
		}
		// Check gamepad control
		else if (l_context == kControlGamepad)
		{
			var flip = false;
			// Check if it's a flipped axes input
			if (l_input < 0)
			{
				l_input = abs(l_input);
				flip = true;
			}
		
			if (l_input == gp_axislh || l_input == gp_axislv
				|| l_input == gp_axisrh || l_input == gp_axisrv)
			{
				var value_in = deadzone_bias(gamepad_axis_value(0, l_input)) * (flip ? -1.0 : 1.0);
				value += _controlParseCheckType(max(0.0, value_in), kControlGamepad);
			}
			else
			{
				value += _controlParseCheckType(gamepad_button_check(0, l_input), kControlGamepad);
			}
		}
	
		// Skip if value is super high
		if (value >= 0.99)
			break;
	}

	return value;


}
