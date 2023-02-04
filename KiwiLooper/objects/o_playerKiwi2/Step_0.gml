/// @description Run input, override camera

PlayerControl_Step();

// Update control & motion
Character_Step();

// Update camera after the motion has been done
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

	o_Camera3D.znear = 200; // todo?

	var kCameraDistance = 600 * cameraZoom;
	if (debug_camera_state == 1)
	{
		kCameraDistance = 300 * cameraZoom;
		o_Camera3D.znear = 100; // todo?
	}
	if (debug_camera_state == 2)
	{
		kCameraDistance = 100 * cameraZoom;
		o_Camera3D.znear = 10; // todo?
	}
	o_Camera3D.x = lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	// Was used for centering in the map
	//o_Camera3D.x += (m_minPosition.x + m_maxPosition.x) * 0.5;
	//o_Camera3D.y += (m_minPosition.y + m_maxPosition.y) * 0.5;
	o_Camera3D.x += lerp(x, xstart, saturate(smoothstep(deathTimer)));
	o_Camera3D.y += lerp(y, ystart, saturate(smoothstep(deathTimer)));
	o_Camera3D.z += lerp(z, zstart, saturate(smoothstep(deathTimer)));

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
	
	if (debug_camera_state == 1)
	{
		o_Camera3D.fov_vertical = 20;
	}
	if (debug_camera_state == 2)
	{
		o_Camera3D.fov_vertical = 60;
	}
	
	o_Camera3D.updateVectors();
	
	// Update listener too
	faudioListenerSetPosition(Audio.mainListener, x, y, z);
	faudioListenerSetOrientation(Audio.mainListener,
		lengthdir_x(-1, o_Camera3D.zrotation), lengthdir_y(-1, o_Camera3D.zrotation), 0,
		0, 0, 1);
}

if (keyboard_check_pressed(vk_numpad0))
{
	debug_camera_state = (debug_camera_state + 1) % 3;
}