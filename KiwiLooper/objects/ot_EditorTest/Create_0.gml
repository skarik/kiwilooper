/// @description Set up camera & routines.

event_inherited();

x = 0;
y = 0;
z = 0;

CameraSetup = function()
{
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;
	
	zstart = z;
}
CameraUpdate = function()
{
	o_Camera3D.zrotation = cameraRotZ;
	o_Camera3D.yrotation = cameraRotY;

	var kCameraDistance = 1200 * cameraZoom;
	o_Camera3D.x = lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
}

GizmoSetup = function()
{
	m_gizmoObject = inew(ob_3DObject);
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.

		draw_set_color(c_white);
		draw_rectangle(16, 16, 32, 32, true);
		draw_rectangle(-16, 16, -32, 32, true);
		draw_rectangle(16, -16, 32, -32, true);
		draw_rectangle(-16, -16, -32, -32, true);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(f_Oxygen7);
		draw_text(32+4, 16, "+x");
		draw_text(16, 32+4, "+y");
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(-32-4, -16, "-x");
		draw_text(-16, -32-4, "-y");
	}
}


CameraSetup();
GizmoSetup();