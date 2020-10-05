/// @description Set up positioning

c3d_declareDefaultTransform();

fov_vertical = 65;
ortho_vertical = GameCamera.height * 0.5;
orthographic = false;
clear_color = c_gray;

// override render order
depth = -10;

// current state
m_viewprojection = matrix_build_identity();

/// @function camera.positionToView(x, y, z)
/// @desc Transforms 3D position into 2D position
/// @param x {Real}
/// @param y {Real}
/// @param z {Real}
positionToView = function(n_x, n_y, n_z)
{
	var test_point = matrix_transform_vertex(m_viewprojection, n_x, n_y, n_z);
	test_point[0] = ((test_point[0] / test_point[2]) * 0.35 + 0.5) * GameCamera.width;
	test_point[1] = ((-test_point[1] / test_point[2]) * 0.35 + 0.5) * GameCamera.height;
	return [test_point[0], test_point[1]];
}

// update game camera
with (GameCamera)
{
	x = width / 2;
	y = height / 2;
	event_user(1);
}

// start up lighting
lightInitialize();