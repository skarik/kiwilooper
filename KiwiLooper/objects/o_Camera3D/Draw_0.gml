/// @description Draw 3D Scene into surface then copy to screen

// Start by doing all the pre-frame work
AtlasPushToGPU(); // TODO: organize this draw call better

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
		mat_projection = matrix_build_projection_perspective_fov(fov_vertical * (GameCamera.height / min(GameCamera.width, GameCamera.height)), Screen.width / Screen.height, znear, zfar);
	else
		mat_projection = matrix_build_projection_ortho(GameCamera.width * ortho_vertical / GameCamera.height, ortho_vertical, 1, zfar);
		
	var forwardAndUp = Vector3ForwardAndUpFromAngles(xrotation, yrotation, zrotation);
	m_viewForward	= forwardAndUp[0].asArray();
	m_viewUp		= forwardAndUp[1].asArray();
	delete forwardAndUp[0];
	delete forwardAndUp[1];
	var mat_view = matrix_build_lookat(
		// from
		x, y, z,
		// to
		x + m_viewForward[0], y + m_viewForward[1], z + m_viewForward[2],
		// up
		m_viewUp[0], m_viewUp[1], m_viewUp[2]);
		
	matrix_set(matrix_view, mat_view);
	matrix_set(matrix_projection, mat_projection);
	
	m_viewprojection = matrix_multiply(mat_view, mat_projection);
	m_viewprojectionInverse = CE_MatrixClone(m_viewprojection);
	CE_MatrixInverse(m_viewprojectionInverse);
	
	m_matrixView = mat_view;
	m_matrixProjection = mat_projection;

	// enable depth testing
	gpu_set_ztestenable(true);
	gpu_set_zfunc(cmpfunc_lessequal);
	
	// grab lighting arrays
	var lightParams = lightGatherLights();
	
	// disable alpha blending
	gpu_set_alphatestenable(true);
	gpu_set_alphatestref(0.5);
	
	var RenderLitObjects = function()
	{
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
	}
	
	//gpu_set_cullmode(cull_counterclockwise); // TODO
	gpu_set_cullmode(cull_noculling); // TODO
	
	// draw all objects
	if (global.lightingMode == kLightingModeForward)
	{
		drawShaderSet(sh_litEnvironment);
		lightPushUniforms(lightParams);
		RenderLitObjects();
		drawShaderReset();
	}
	else if (global.lightingMode == kLightingModeDeferred)
	{
		surface_reset_target(); // Reset our rendering target
		
		// the main surface is now on buffer_scene3d
		// we need a few other buffers
		var buffer_albedo  = surface_create(GameCamera.width, GameCamera.height);
		var buffer_normals = surface_create(GameCamera.width, GameCamera.height);
		var buffer_illumin = surface_create(GameCamera.width, GameCamera.height);
		var buffer_depth   = surface_create(GameCamera.width, GameCamera.height);
		
		surface_clear_color_alpha(buffer_albedo,  c_black, 0.0);
		surface_clear_color_alpha(buffer_normals, c_black, 0.0);
		surface_clear_color_alpha(buffer_illumin, c_black, 0.0);
		surface_clear_color_alpha(buffer_depth, c_black, 0.0);
				
		// set the buffers we're going to render to
		surface_set_target(buffer_scene3d); // Use 3d scene's depth buffer
		//surface_set_target_ext(0, buffer_albedo);
		surface_set_target_ext(1, buffer_normals);
		surface_set_target_ext(2, buffer_illumin);
		surface_set_target_ext(3, buffer_depth);
		
		{ // surface_reset_target() also resets the view projection matrices
			matrix_set(matrix_view, mat_view);
			matrix_set(matrix_projection, mat_projection);
		}
		
		// Set up the gather, and render all the objects
		drawShaderSet(sh_gatherEnvironment);
		lightPushGatherUniforms_Deferred();
		RenderLitObjects();
		drawShaderReset();
		
		// Reset all the bindings (the surface_set_target_ext(0,...) is another item on the stack)
		//surface_reset_target();
		surface_reset_target();
		
		// Render to buffer_scene3d for our compositing:
		
		gpu_set_ztestenable(false);
		gpu_set_zwriteenable(false);
		gpu_set_zfunc(cmpfunc_always);
		
		// Copy to the albedo
		{	// reset the matrices for the copy since they're inconsistent at this point
			matrix_set(matrix_world, mat_world_previous);
			matrix_set(matrix_view, mat_view_previous);
			matrix_set(matrix_projection, mat_projection_previous);
		}
		surface_copy(buffer_albedo, 0, 0, buffer_scene3d);
		
		// now composite to the main scene
		surface_set_target(buffer_scene3d);
		
		{ // surface_reset_target() also resets the view projection matrices
			matrix_set(matrix_view, mat_view);
			matrix_set(matrix_projection, mat_projection);
		}
		
		/*drawShaderSet(sh_compositeLighting);
		lightPushUniforms(lightParams);
		texture_set_stage(global.deferred_samplers.textureAlbedo, surface_get_texture(buffer_albedo));
		texture_set_stage(global.deferred_samplers.textureNormal, surface_get_texture(buffer_normals));
		texture_set_stage(global.deferred_samplers.textureDepth,  surface_get_texture(buffer_depth));
		// Draw a quad using the albedo
		draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture(buffer_albedo));
			draw_vertex_texture(-1, -1, 0, 1);
			draw_vertex_texture(1, -1, 1, 1);
			draw_vertex_texture(-1, 1, 0, 0);
			draw_vertex_texture(1, 1, 1, 0);
		draw_primitive_end();
		drawShaderReset();*/
		
		if (global.shadeType == kShadeTypeDefault
			|| global.shadeType == kShadeTypeDebug_Lighting)
		{
			drawShaderSet(sh_lightAmbient);
			lightDeferredPushUniforms_Ambient(buffer_albedo, buffer_normals, buffer_illumin, buffer_depth);
			// Draw a quad using the albedo
			draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture(buffer_albedo));
				draw_vertex_texture(-1, -1, 0, 1);
				draw_vertex_texture(1, -1, 1, 1);
				draw_vertex_texture(-1, 1, 0, 0);
				draw_vertex_texture(1, 1, 1, 0);
			draw_primitive_end();
			drawShaderReset();
		
			gpu_set_blendmode_ext_sepalpha(bm_one, bm_one, bm_zero, bm_one);
		
			//drawShaderSet(sh_lightPoint);
			//lightDeferredPushUniforms_Point(lightParams, buffer_albedo, buffer_normals, buffer_depth);
			drawShaderSet(sh_lightGeneral);
			lightDeferredPushUniforms_General(lightParams, buffer_albedo, buffer_normals, buffer_depth);
				var allLights = lightParams.lightlist;
				// loop through all the lights
				for (var lightIndex = 0; lightIndex < array_length(allLights); ++lightIndex)
				{
					//var light = allLights[lightIndex];
					//lightDeferredPushUniforms_Point_Index(lightIndex);
					lightDeferredPushUniforms_General_Index(lightIndex);
					draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture(buffer_albedo));
						draw_vertex_texture(-1, -1, 0, 1);
						draw_vertex_texture(1, -1, 1, 1);
						draw_vertex_texture(-1, 1, 0, 0);
						draw_vertex_texture(1, 1, 1, 0);
					draw_primitive_end();
				}
			drawShaderReset();
		}
		else
		{
			// Draw single quad w/ the given debug mode
			drawShaderSet(sh_lightGeneral);
			lightDeferredPushUniforms_General(lightParams, buffer_albedo, buffer_normals, buffer_depth);
				draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture(buffer_albedo));
					draw_vertex_texture(-1, -1, 0, 1);
					draw_vertex_texture(1, -1, 1, 1);
					draw_vertex_texture(-1, 1, 0, 0);
					draw_vertex_texture(1, 1, 1, 0);
				draw_primitive_end();
			drawShaderReset();
		}
		
		surface_free(buffer_albedo);
		surface_free(buffer_normals);
		surface_free(buffer_illumin);
		surface_free(buffer_depth);
		
		gpu_set_blendmode(bm_normal);
		
		gpu_set_ztestenable(true);
		gpu_set_zwriteenable(true);
		gpu_set_zfunc(cmpfunc_lessequal);
	}
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