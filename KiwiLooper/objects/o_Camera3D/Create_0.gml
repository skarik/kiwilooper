/// @description Set up positioning

c3d_declareDefaultTransform();

fov_vertical = 65;
ortho_vertical = GameCamera.height * 0.5;
orthographic = false;
clear_color = c_gray;

#macro kCameraDefaultZNear 600
#macro kCameraDefaultZFar 4000
znear = 600;
zfar = 4000;

// override render order
depth = -10;

// current state
m_viewprojection = matrix_build_identity();
m_viewprojectionInverse = CE_MatrixClone(m_viewprojection);

// TODO: fix this properly
m_matrixView = matrix_build_identity();
m_matrixProjection = matrix_build_identity();

m_viewForward = [1, 0, 0];
m_viewUp = [0, 0, 1];

///@function camera.positionToView(x, y, z)
///@desc Transforms 3D position into 2D position
///@param x {Real}
///@param y {Real}
///@param z {Real}
positionToView = function(n_x, n_y, n_z)
{
	// w-coordinate divide is not handled in matrix_transform_vertex
	
	var input_point = new Vector4(n_x, n_y, n_z, 1.0);
	input_point.transformAMatrixSelf(m_viewprojection);
	
	var test_point = input_point.getXYZ();
	test_point.multiplySelf(1.0 / input_point.w);
	
	return [
		( test_point.x * 0.5 + 0.5) * GameCamera.width,
		(-test_point.y * 0.5 + 0.5) * GameCamera.height,
		test_point.z
		];
}

///@function camera.viewToRay(x, y)
///@desc Transforms 2D position into a 3D ray for the camera
///@param x {Real}
///@param y {Real}
viewToRay = function(n_x, n_y)
{
	// w-coordinate divide is not handled in matrix_transform_vertex
	
	var view_x = (GameCamera.width <= 0) ? 0.0 : ((n_x / GameCamera.width) - 0.5) * 2;
	var view_y = (GameCamera.height <= 0) ? 0.0 : -((n_y / GameCamera.height) - 0.5) * 2;
	
	var input_point = new Vector4(view_x, view_y, 1.0, 1.0);
	input_point.transformAMatrixSelf(m_viewprojectionInverse);
	
	var test_point = input_point.getXYZ();
	test_point.multiplySelf(1.0 / input_point.w);
	test_point.subtractSelf(new Vector3(x, y, z));
	test_point.normalize();
	
	return [
		test_point.x,
		test_point.y,
		test_point.z 
		];
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