/// @description Draw 3D Scene into surface then copy to screen

// Create buffer to render to
var buffer_scene3d = surface_create(GameCamera.width, GameCamera.height);
surface_set_target(buffer_scene3d);
{
	draw_clear_alpha(clear_color, 1.0);
	
	// Draw starry background
	draw_sprite_tiled(sui_starbackground, 0, zrotation * GameCamera.width / 90, -yrotation * GameCamera.height / 90);
	
	// Save old matrix stack
	var mat_world_previous = matrix_get(matrix_world);
	var mat_view_previous = matrix_get(matrix_view);
	var mat_projection_previous = matrix_get(matrix_projection);
	
	// Create transformation
	var mat_projection;
	if (!orthographic)
		mat_projection = matrix_build_projection_perspective_fov(fov_vertical, Screen.width / Screen.height, 600, 4000);
	else
		mat_projection = matrix_build_projection_ortho(GameCamera.width * ortho_vertical / GameCamera.height, ortho_vertical, 1, 4000);
	var mat_view = matrix_build_lookat(
		// from
		x, y, z,
		// to
		x + lengthdir_x(1.0, zrotation) * lengthdir_x(1.0, yrotation), 
		y + lengthdir_y(1.0, zrotation) * lengthdir_x(1.0, yrotation), 
		z + lengthdir_y(1.0, yrotation),
		// up
		lengthdir_y(1.0, zrotation) * lengthdir_y(1.0, xrotation) - lengthdir_x(1.0, zrotation) * lengthdir_y(1.0, yrotation),
		-lengthdir_x(1.0, zrotation) * lengthdir_y(1.0, xrotation) - lengthdir_y(1.0, zrotation) * lengthdir_y(1.0, yrotation),
		lengthdir_x(1.0, yrotation) * lengthdir_x(1.0, xrotation));
		
	matrix_set(matrix_view, mat_view);
	matrix_set(matrix_projection, mat_projection);
	
	/*var mat_viewprojection = matrix_multiply(mat_view, mat_projection);
	if (iexists(o_charaRobot))
	{
		var test_point = matrix_transform_vertex(mat_viewprojection, o_charaRobot.x, o_charaRobot.y, o_charaRobot.z);
		//show_debug_message("{ " + string(test_point[0]) + ", " + string(test_point[1]) + ", " + string(test_point[2]) + "}");
		test_point[0] = ((test_point[0] / test_point[2]) * 0.5 + 0.5) * GameCamera.width;
		test_point[1] = ((-test_point[1] / test_point[2]) * 0.5 + 0.5) * GameCamera.height;
		show_debug_message("{ " + string(test_point[0]) + ", " + string(test_point[1]) + "}");
	}*/
	
	m_viewprojection = matrix_multiply(mat_view, mat_projection);
	m_viewprojectionInverse = amatrix_clone(m_viewprojection);
	amatrix_inverse(m_viewprojectionInverse);

	// enable depth testing
	gpu_set_ztestenable(true);
	gpu_set_zfunc(cmpfunc_lessequal);
	
	// grab lighting arrays
	var lightParams = lightGatherLights();
	
	// disable alpha blending
	gpu_set_alphatestenable(true);
	gpu_set_alphatestref(0.5);
	
	// draw all objects
	drawShaderSet(sh_litEnvironment);
	lightPushUniforms(lightParams);
	with (ob_3DObject)
	{
		if (visible && !translucent && lit)
		{
			var mat_object_pos = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);
			var mat_object_scal = matrix_build(0, 0, 0, 0, 0, 0, xscale, yscale, zscale);
			var mat_object_rotx = matrix_build(0, 0, 0, xrotation, 0, 0, 1, 1, 1);
			var mat_object_roty = matrix_build(0, 0, 0, 0, yrotation, 0, 1, 1, 1);
			var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, zrotation, 1, 1, 1);
		
			var mat_object = mat_object_scal;
			mat_object = matrix_multiply(mat_object, mat_object_rotx);
			mat_object = matrix_multiply(mat_object, mat_object_roty);
			mat_object = matrix_multiply(mat_object, mat_object_rotz);
			mat_object = matrix_multiply(mat_object, mat_object_pos);
			matrix_set(matrix_world, mat_object);
			m_renderEvent();
		}
	}
	drawShaderReset();
	// draw unlit
	with (ob_3DObject)
	{
		if (visible && !translucent && !lit)
		{
			var mat_object_pos = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);
			var mat_object_scal = matrix_build(0, 0, 0, 0, 0, 0, xscale, yscale, zscale);
			var mat_object_rotx = matrix_build(0, 0, 0, xrotation, 0, 0, 1, 1, 1);
			var mat_object_roty = matrix_build(0, 0, 0, 0, yrotation, 0, 1, 1, 1);
			var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, zrotation, 1, 1, 1);
		
			var mat_object = mat_object_scal;
			mat_object = matrix_multiply(mat_object, mat_object_rotx);
			mat_object = matrix_multiply(mat_object, mat_object_roty);
			mat_object = matrix_multiply(mat_object, mat_object_rotz);
			mat_object = matrix_multiply(mat_object, mat_object_pos);
			matrix_set(matrix_world, mat_object);
			m_renderEvent();
		}
	}
	
	// enable alpha blending
	gpu_set_alphatestenable(false);
	
	// draw translucents after
	with (ob_3DObject)
	{
		if (visible && translucent)
		{
			var mat_object_pos = matrix_build(x, y, z, 0, 0, 0, 1, 1, 1);
			var mat_object_scal = matrix_build(0, 0, 0, 0, 0, 0, xscale, yscale, zscale);
			var mat_object_rotx = matrix_build(0, 0, 0, xrotation, 0, 0, 1, 1, 1);
			var mat_object_roty = matrix_build(0, 0, 0, 0, yrotation, 0, 1, 1, 1);
			var mat_object_rotz = matrix_build(0, 0, 0, 0, 0, zrotation, 1, 1, 1);
		
			var mat_object = mat_object_scal;
			mat_object = matrix_multiply(mat_object, mat_object_rotx);
			mat_object = matrix_multiply(mat_object, mat_object_roty);
			mat_object = matrix_multiply(mat_object, mat_object_rotz);
			mat_object = matrix_multiply(mat_object, mat_object_pos);
			matrix_set(matrix_world, mat_object);
			m_renderEvent();
		}
	}
	
	// Reset to old matrix stack
	matrix_set(matrix_world, mat_world_previous);
	matrix_set(matrix_view, mat_view_previous);
	matrix_set(matrix_projection, mat_projection_previous);

	// disable depth testing
	gpu_set_ztestenable(false);
	gpu_set_zfunc(cmpfunc_always);
	
	// disable alpha testing
	gpu_set_alphatestenable(false);
	
	// fix alpha channel
	gpu_set_blendmode_ext_sepalpha(bm_zero, bm_one, bm_one, bm_one);
	draw_set_color(c_black);
	draw_rectangle(-10000, -10000, 10000, 10000, false);
	gpu_set_blendmode(bm_normal);
}
surface_reset_target();

// Draw surface on-screen
draw_surface(buffer_scene3d, 0, 0);

// done with surface, so free it up
surface_free(buffer_scene3d);

// color correction
/*gpu_set_blendmode_ext(bm_dest_colour, bm_src_colour);
draw_circle_color(
	GameCamera.width / 2, GameCamera.height / 2 - 30, GameCamera.width * 0.8,
	make_color_rgb(135, 135, 135),
	//make_color_rgb(44, 75, 115),
	make_color_rgb(85, 84, 115),
	false);
gpu_set_blendmode(bm_normal);*/