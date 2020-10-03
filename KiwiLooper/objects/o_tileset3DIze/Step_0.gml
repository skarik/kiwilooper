/// @description Set up shit


//o_Camera3D.zrotation = 45;
o_Camera3D.zrotation += Time.deltaTime * 45;
o_Camera3D.yrotation = 60;

var kCameraDistance = 1200;
o_Camera3D.x = lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
o_Camera3D.y = lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
o_Camera3D.z = lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

o_Camera3D.x += (m_minPosition.x + m_maxPosition.x) * 0.5;
o_Camera3D.y += (m_minPosition.y + m_maxPosition.y) * 0.5;

o_Camera3D.orthographic = false;
o_Camera3D.fov_vertical = 10;