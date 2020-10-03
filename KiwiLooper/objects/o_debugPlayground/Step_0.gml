/// @description Mouse logic

var windowMouseX = window_mouse_get_x();
var windowMouseY = window_mouse_get_y();
uPosition = round(windowMouseX / Screen.pixelScale + GameCamera.view_x);
vPosition = round(windowMouseY / Screen.pixelScale + GameCamera.view_y);
			
// Middle click drag view
if (mouse_check_button_pressed(mb_middle))
{
	m_control_dragging = true;
	m_control_drag_origin = [x, y];
	m_control_drag_reference = [windowMouseX, windowMouseY];
}
if (mouse_check_button_released(mb_middle))
{
	m_control_dragging = false;
}
if (m_control_dragging)
{
	x = m_control_drag_origin[0] + (m_control_drag_reference[0] - windowMouseX) / Screen.pixelScale;
	y = m_control_drag_origin[1] + (m_control_drag_reference[1] - windowMouseY) / Screen.pixelScale;
}

// Spawn things
if (keyboard_check_pressed(ord("1")))
{
	instance_create_depth(uPosition, vPosition, 0, o_chNathan);
}
if (keyboard_check_pressed(ord("2")))
{
	instance_create_depth(uPosition, vPosition, 0, o_chOasisNpc);
}
if (keyboard_check_pressed(ord("3")))
{
	instance_create_depth(uPosition, vPosition, 0, o_chMithraNpc);
}


// Select NPCs
if (mouse_check_button_pressed(mb_left))
{
	m_npc_selection = collision_rectangle(
		uPosition - 8, vPosition - 8,
		uPosition + 8, vPosition + 8,
		ob_character,
		false, true);
}

// Give NPC commands
if (iexists(m_npc_selection))
{
	if (mouse_check_button_pressed(mb_right))
	{
		aiscriptRequestMove(
			m_npc_selection,
			kAiStyle_Scripted, 
			uPosition,
			vPosition,
			1.0);
	}
}