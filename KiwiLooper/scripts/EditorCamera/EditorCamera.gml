function EditorCameraSetup()
{
	cameraX = 0;
	cameraY = 0;
	cameraZ = 0;
	
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;
	
	zstart = z;
}
function EditorCameraUpdate()
{
	o_Camera3D.zrotation = cameraRotZ;
	o_Camera3D.yrotation = cameraRotY;

	var kCameraDistance = 1200 * cameraZoom;
	o_Camera3D.x = cameraX + lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = cameraY + lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = cameraZ + lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
	
	o_Camera3D.znear = kCameraDefaultZNear * cameraZoom;
	o_Camera3D.zfar = max(kCameraDefaultZFar, kCameraDefaultZFar * cameraZoom);
}
