/// @description controlGetName(control_type, pad_type, control)
/// @param control_type {kControl} Is ``lastControlType`` in a controlled object.
/// @param pad_type (kGamepadType} Is ``lastGamepadType`` in a controlled object.
/// @param control {Real} Input value to draw.
function controlGetName(argument0, argument1, argument2) {

	var ctype = argument0;
	var pad_type = argument1;
	var c = argument2;

	if (ctype == kControlKB)
	{
		switch (c)
		{
		    case vk_left:       return "Left";
		    case vk_right:      return "Right";
		    case vk_up:         return "Up";
		    case vk_down:       return "Down";
		
		    case vk_space:      return "Space";
			case vk_return:		return "Enter";
			case vk_escape:		return "Escape";
			case vk_tab:		return "Tab";
			case vk_backspace:	return "Backspace";
			case vk_delete:		return "Delete";
			case vk_pageup:		return "Page Up";
			case vk_pagedown:	return "Page Down";
		
			case vk_control:	return "Control";
			case vk_shift:		return "Shift";
			case vk_alt:		return "Alt";
		
			case vk_lcontrol:	return "Left Control";
			case vk_rcontrol:	return "Right Control";
			case vk_lshift:		return "Left Shift";
			case vk_rshift:		return "Right Shift";
			case vk_lalt:		return "Left Alt";
			case vk_ralt:		return "Right Alt";
		
			case vk_numpad0:	return "Numpad 0";
			case vk_numpad1:	return "Numpad 1";
			case vk_numpad2:	return "Numpad 2";
			case vk_numpad3:	return "Numpad 3";
			case vk_numpad4:	return "Numpad 4";
			case vk_numpad5:	return "Numpad 5";
			case vk_numpad6:	return "Numpad 6";
			case vk_numpad7:	return "Numpad 7";
			case vk_numpad8:	return "Numpad 8";
			case vk_numpad9:	return "Numpad 9";
    
		    default:        return chr(c);
		}
	}
	else if (ctype == kControlGamepad)
	{
		var generic = (pad_type == kGamepadTypeGeneric);
		var ds = (pad_type == kGamepadTypeDualshock);
	
		switch (c)
		{
			case gp_face1:		return generic ? "Button 1" : (ds ? "Cross" : "A");
			case gp_face2:		return generic ? "Button 2" : (ds ? "Circle" : "B");
			case gp_face3:		return generic ? "Button 3" : (ds ? "Square" : "X");
			case gp_face4:		return generic ? "Button 4" : (ds ? "Triangle" : "Y");
		
			case gp_shoulderl:	return generic ? "L Shoulder" : (ds ? "L1" : "LB");
			case gp_shoulderr:	return generic ? "R Shoulder" : (ds ? "R1" : "RB");
			case gp_shoulderlb:	return generic ? "L Trigger" : (ds ? "L2" : "LT");
			case gp_shoulderrb:	return generic ? "R Trigger" : (ds ? "R2" : "RT");
		
			case gp_select:		return generic ? "Select" : (ds ? "PS Button" : "Listing");
			case gp_start:		return generic ? "Start" : (ds ? "Option" : "Option");
		
			case gp_stickl:		return generic ? "Left Stick" : (ds ? "L3 (Stick)" : "Left Stick");
			case gp_stickr:		return generic ? "Right Stick" : (ds ? "R3 (Stick)" : "Right Stick");
			case gp_axislh:		return "LS Horizontal";
			case gp_axislv:		return "LS Vertical";
			case gp_axisrh:		return "RS Horizontal";
			case gp_axisrv:		return "RS Vertical";
		
			case gp_padu:		return "D-pad Up";
			case gp_padd:		return "D-pad Down";
			case gp_padl:		return "D-pad Left";
			case gp_padr:		return "D-pad Right";
		}
	}
	else if (ctype == kControlMouse)
	{
		switch (c)
		{
			case mb_left:		return "Left Mouse Button";
			case mb_right:		return "Right Mouse Button";
			case mb_middle:		return "Middle Mouse Button";
			case kMouseWheelUp:	return "Scroll Up";
			case kMouseWheelDown:	return "Scroll Down";
		}
	}

	return c;


}
