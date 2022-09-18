function EditorCameraSetup()
{
	// state moved to this.state
	/*cameraX = 0;
	cameraY = 0;
	cameraZ = 0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;*/
	
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	zstart = z;
}
function EditorCameraUpdate()
{
	o_Camera3D.zrotation = m_state.camera.rotation.z;
	o_Camera3D.yrotation = m_state.camera.rotation.y;

	var kCameraDistance = 1200 * m_state.camera.zoom;
	o_Camera3D.x = m_state.camera.position.x + lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = m_state.camera.position.y + lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = m_state.camera.position.z + lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
	
	o_Camera3D.znear = kCameraDefaultZNear * m_state.camera.zoom;
	o_Camera3D.zfar = max(kCameraDefaultZFar, kCameraDefaultZFar * m_state.camera.zoom);
	
	
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
		}
	}
}
