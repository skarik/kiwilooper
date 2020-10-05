function PlayerControl_Create()
{
	isPlayer = true;
	
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;
}

function PlayerControl_Step()
{
	controlUpdate(iexists(o_uisLogBox));
}

function PlayerControl_UpdateCamera()
{
	// Horizontal camera
	if (abs(uAxis.value) > 0.0)
	{
		cameraRotZSpeed = 
			sign(uAxis.value) *
			min(
				// Max speed
				140.0 * abs(uAxis.value), 
				// Acceleration + quick turn
				max(0.0, cameraRotZSpeed * sign(uAxis.value)) + Time.deltaTime * 600.0
				);
	}
	else
	{
		// Decelleration
		cameraRotZSpeed = sign(cameraRotZSpeed) * max(0.0, abs(cameraRotZSpeed) - Time.deltaTime * 2000.0);
	}
	
	// Vertical camera
	if (abs(vAxis.value) > 0.0)
	{
		cameraRotYSpeed = 
			sign(-vAxis.value) *
			min(
				// Max speed
				60.0 * abs(-vAxis.value), 
				// Acceleration + quick turn
				max(0.0, cameraRotYSpeed * sign(-vAxis.value)) + Time.deltaTime * 200.0
				);
	}
	else
	{
		// Decelleration
		cameraRotYSpeed = sign(cameraRotYSpeed) * max(0.0, abs(cameraRotYSpeed) - Time.deltaTime * 2000.0);
	}
	
	cameraRotZ += cameraRotZSpeed * Time.deltaTime;
	cameraRotY += cameraRotYSpeed * Time.deltaTime;
	// Limit Y rotation
	cameraRotY = clamp(cameraRotY, 30, 85);
	
	o_Camera3D.zrotation = cameraRotZ;
	o_Camera3D.yrotation = cameraRotY;

	var kCameraDistance = 1200 * cameraZoom;
	o_Camera3D.x = lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	// Was used for centering in the map
	//o_Camera3D.x += (m_minPosition.x + m_maxPosition.x) * 0.5;
	//o_Camera3D.y += (m_minPosition.y + m_maxPosition.y) * 0.5;
	o_Camera3D.x += x;
	o_Camera3D.y += y;
	o_Camera3D.z += z;

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
	
	// Update listener too
	faudioListenerSetPosition(Audio.mainListener, x, y, z);
	faudioListenerSetOrientation(Audio.mainListener,
		lengthdir_x(-1, o_Camera3D.zrotation), lengthdir_y(-1, o_Camera3D.zrotation), 0,
		0, 0, 1);
}