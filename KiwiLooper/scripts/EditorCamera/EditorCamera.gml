function EditorCameraSetup()
{
	zstart = z;
	
	firstPersonBlend = 0.0;
}
function EditorCameraUpdate()
{
	// Do blending between modes
	if (m_state.camera.mode == 0)
	{
		firstPersonBlend = max(0.0, firstPersonBlend - Time.deltaTime * 5.0);
	}
	else
	{
		firstPersonBlend = min(1.0, firstPersonBlend + Time.deltaTime * 5.0);
	}
	
	// Do initial FP setup
	if (m_state.camera.mode == 1 && !m_state.camera.fp_ready)
	{
		m_state.camera.fp_ready = true;
		m_state.camera.fp_rotation.z = m_state.camera.rotation.z;
		m_state.camera.fp_z = m_state.camera.position.z + 16;
	}
	
	// Temp vars
	var mainview_position = new Vector3(), mainview_rotation = new Vector3(), mainview_fov = 0, mainview_znear = 0, mainview_zfar = 0;
	var firstper_position = new Vector3(), firstper_rotation = new Vector3(), firstper_fov = 0, firstper_znear = 0, firstper_zfar = 0;
	
	//if (firstPersonBlend < 1.0)
	{
		mainview_rotation = m_state.camera.rotation.copy();
		mainview_position = m_state.camera.position.copy();
		
		var kCameraDistance = 1200 * m_state.camera.zoom;
		mainview_position.x += lengthdir_x(-kCameraDistance, mainview_rotation.z) * lengthdir_x(1, mainview_rotation.y);
		mainview_position.y += lengthdir_y(-kCameraDistance, mainview_rotation.z) * lengthdir_x(1, mainview_rotation.y);
		mainview_position.z += lengthdir_y(-kCameraDistance, mainview_rotation.y);
		
		mainview_fov = 10;
		
		mainview_znear = kCameraDefaultZNear * m_state.camera.zoom;
		mainview_zfar = max(kCameraDefaultZFar, kCameraDefaultZFar * m_state.camera.zoom);
	}
	//else if (firstPersonBlend > 0.0)
	{
		firstper_rotation = m_state.camera.fp_rotation.copy();
		firstper_position = m_state.camera.position.copy();
		firstper_position.z = m_state.camera.fp_z;
		
		firstper_fov = 60;
		
		firstper_znear = 1;
		firstper_zfar = kCameraDefaultZFar;
	}
	
	// Perform blends for final position. Some hacky math for smoother experience
	var smooth_blend = smoothstep(firstPersonBlend);
	
	var final_position = mainview_position.linearlerp(firstper_position, 1.0 - power(1.0 - smooth_blend, 4));
	var final_rotation = mainview_rotation.anglelerp(firstper_rotation, smooth_blend);
	
	var final_fov	= lerp(mainview_fov, firstper_fov, sqr(smooth_blend));
	var final_znear	= lerp(mainview_znear, firstper_znear, 1.0 - power(1.0 - smooth_blend, 5));
	var final_zfar	= lerp(mainview_zfar,  firstper_zfar,  1.0 - power(1.0 - smooth_blend, 5));
	
	// Apply finals
	o_Camera3D.orthographic = false;
	
	o_Camera3D.zrotation = final_rotation.z;
	o_Camera3D.yrotation = final_rotation.y;
	
	o_Camera3D.x = final_position.x;
	o_Camera3D.y = final_position.y;
	o_Camera3D.z = final_position.z;
	
	o_Camera3D.fov_vertical = final_fov;
	
	o_Camera3D.znear = final_znear;
	o_Camera3D.zfar = final_zfar;
	
	// Delete temp vars
	delete mainview_position;
	delete mainview_rotation;
	delete firstper_position;
	delete firstper_rotation;
	delete final_position;
	delete final_rotation;
	
	// Update listener too
	faudioListenerSetPosition(Audio.mainListener, m_state.camera.position.x, m_state.camera.position.y, m_state.camera.position.z);
	faudioListenerSetOrientation(Audio.mainListener,
		lengthdir_x(-1, o_Camera3D.zrotation), lengthdir_y(-1, o_Camera3D.zrotation), 0,
		0, 0, 1);
}

function EditorCameraCenterOnSelection()
{
	with (EditorGet())
	{
		if (EditorSelectionGetLast() != null)
		{
			var position = EditorSelectionGetLastPosition();
			m_state.camera.position.x = position.x;
			m_state.camera.position.y = position.y;
			m_state.camera.position.z = position.z;
			
			// TODO: set fp_position as well
		}
	}
}
