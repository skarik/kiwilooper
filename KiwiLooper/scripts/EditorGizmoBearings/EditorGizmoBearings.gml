/// @function AEditorGizmoAxes() constructor
/// @desc Editor gizmo for the root axes
function AEditorGizmoAxes() : AEditorGizmoBase() constructor
{
	var kBorderExpand = 10;
	var kAxisLength = 32;
	
	m_mesh = meshb_Begin();
		var color;
		color = merge_color(c_red, c_black, 0.5);
		MeshbAddLine(m_mesh, color, kBorderExpand, kAxisLength, new Vector3(1, 0, 0), new Vector3(0, 0, 0));	// Build line
		// Build letter X
		MeshbAddLine(m_mesh, color, kBorderExpand, 5.7, new Vector3(0.707, 0.707, 0), new Vector3(kAxisLength + 2, -2, 0));
		MeshbAddLine(m_mesh, color, kBorderExpand, 5.7, new Vector3(0.707, -0.707, 0), new Vector3(kAxisLength + 2, 2, 0));
		
		color = merge_color(c_midgreen, c_black, 0.5);
		MeshbAddLine(m_mesh, color, kBorderExpand, kAxisLength, new Vector3(0, 1, 0), new Vector3(0, 0, 0));	// Build line
		// Build letter Y
		MeshbAddLine(m_mesh, color, kBorderExpand, 2.8, new Vector3(0.707, -0.707, 0), new Vector3(-2, kAxisLength + 6, 0));
		MeshbAddLine(m_mesh, color, kBorderExpand, 2.8, new Vector3(0.707, 0.707, 0), new Vector3(-2, kAxisLength + 2, 0));
		MeshbAddLine(m_mesh, color, kBorderExpand, 2, new Vector3(1, 0, 0), new Vector3(0, kAxisLength + 4, 0));
		
		color = merge_color(c_midblue, c_black, 0.5);
		MeshbAddLine(m_mesh, color, kBorderExpand, kAxisLength, new Vector3(0, 0, 1), new Vector3(0, 0, 0));	// Build line
		// Build letter Z
		MeshbAddLine(m_mesh, color, kBorderExpand, 5.7, new Vector3(0.707, 0, 0.707), new Vector3(-2, 0, kAxisLength + 2));
		MeshbAddLine(m_mesh, color, kBorderExpand, 4, new Vector3(1, 0, 0), new Vector3(-2, 0, kAxisLength + 6));
		MeshbAddLine(m_mesh, color, kBorderExpand, 4, new Vector3(1, 0, 0), new Vector3(-2, 0, kAxisLength + 2));
	meshb_End(m_mesh);
	vertex_freeze(m_mesh);
		
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	/// @function Draw
	Draw = function()
	{
		var last_shader = drawShaderGet();
		var last_ztest = gpu_get_zfunc();
		var last_zwrite = gpu_get_zwriteenable();
			
		gpu_set_zwriteenable(false);
			
		drawShaderSet(sh_editorLineEdge);
		shader_set_uniform_f(global.m_editorLineEdge_uLineSizeAndFade, 0.5, 0, 0, 0);
			
		gpu_set_zfunc(cmpfunc_greater);
		shader_set_uniform_f(global.m_editorLineEdge_uLineColor, 0.5, 0.5, 0.5, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		gpu_set_zfunc(last_ztest);
		shader_set_uniform_f(global.m_editorLineEdge_uLineColor, 1.0, 1.0, 1.0, 1.0);
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
		drawShaderSet(last_shader);
		gpu_set_zwriteenable(last_zwrite);
	};
}

/// @function AEditorGizmoGrid() constructor
/// @desc Editor gizmo for the root axes
function AEditorGizmoGrid() : AEditorGizmoBase() constructor
{
	var kBorderExpand = 10;
	
	xscale = 1.0;
	yscale = 1.0;
	zscale = 1.0;
	xrotation = 0;
	yrotation = 0;
	zrotation = 0;
	
	m_mesh = meshb_Begin();
		// Create a 8x8 grid, 16-wide centered around the middle:
		var kCelSize = 16;
		var kCelLength = 8;
		var kCelHLength = kCelLength / 2;
		
		for (var i = -kCelHLength; i <= kCelHLength; ++i)
		{
			var color = c_gray;
			// Add on X
			MeshbAddLine(m_mesh, color, kBorderExpand, kCelLength * kCelSize, new Vector3(1, 0, 0), new Vector3(-kCelHLength * kCelSize, i * kCelSize, 0));
			
			// Add on Y
			MeshbAddLine(m_mesh, color, kBorderExpand, kCelLength * kCelSize, new Vector3(0, 1, 0), new Vector3(i * kCelSize, -kCelHLength * kCelSize, 0));
		}
	meshb_End(m_mesh);
		
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	/// @function Draw
	Draw = function()
	{
		var mat_object_old = matrix_get(matrix_world);
		
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
		{
			var last_shader = drawShaderGet();
			var last_ztest = gpu_get_zfunc();
			var last_zwrite = gpu_get_zwriteenable();
			
			gpu_set_zwriteenable(false);
			
			drawShaderSet(sh_editorLineEdge);
			shader_set_uniform_f(global.m_editorLineEdge_uLineSizeAndFade, 0.5, 0, 0, 0);
			
			gpu_set_zfunc(cmpfunc_greater);
			shader_set_uniform_f(global.m_editorLineEdge_uLineColor, 0.5, 0.5, 0.5, 0.10);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			gpu_set_zfunc(last_ztest);
			shader_set_uniform_f(global.m_editorLineEdge_uLineColor, 1.0, 1.0, 1.0, 0.20);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			drawShaderSet(last_shader);
			gpu_set_zwriteenable(last_zwrite);
		}
		matrix_set(matrix_world, mat_object_old);
	};
}


/// @function AEditorGizmoGridGlobal() constructor
/// @desc Editor gizmo for the root axes
function AEditorGizmoGridGlobal() : AEditorGizmoBase() constructor
{
	xscale = 1.0;
	yscale = 1.0;
	zscale = 1.0;
	xrotation = 0;
	yrotation = 0;
	zrotation = 0;
	
	m_mesh = meshb_Begin();
		var kQuadWidth = 4096;
		// Add a super big quad
		MeshbAddQuad(m_mesh, c_white, new Vector3(kQuadWidth, 0, 0), new Vector3(0, kQuadWidth, 0), new Vector3(-kQuadWidth / 2, -kQuadWidth / 2, 0));
	meshb_End(m_mesh);

	m_stencilBuffer = null;
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	/// @function Draw
	Draw = function()
	{
		var mat_object_old = matrix_get(matrix_world);
		
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
		if (surface_exists(m_stencilBuffer))
		{
			static sh_editorGridSurface_uGridInfo = shader_get_uniform(sh_editorGridSurface, "uGridInfo");
			static sh_editorGridSurface_uGridColorCenter = shader_get_uniform(sh_editorGridSurface, "uGridColorCenter");
			static sh_editorGridSurface_uGridColorBigDiv = shader_get_uniform(sh_editorGridSurface, "uGridColorBigDiv");
			static sh_editorGridSurface_uGridColorNormal = shader_get_uniform(sh_editorGridSurface, "uGridColorNormal");
			static sh_editorGridSurface_textureSkip = shader_get_sampler_index(sh_editorGridSurface, "textureSkip");
			
			drawShaderStore();
			gpu_push_state();
			
			gpu_set_zwriteenable(false);
			gpu_set_cullmode(cull_noculling);
			
			drawShaderSet(sh_editorGridSurface);
			shader_set_uniform_f(sh_editorGridSurface_uGridInfo, m_editor.toolGridSize, m_editor.toolGridSize * 8.0, 1.0, 0);
			shader_set_uniform_f(sh_editorGridSurface_uGridColorCenter, 1.0, 1.0, 1.0, 0.15);
			shader_set_uniform_f(sh_editorGridSurface_uGridColorBigDiv, 0.5, 0.8, 0.8, 0.15);
			shader_set_uniform_f(sh_editorGridSurface_uGridColorNormal, 0.5, 0.5, 0.5, 0.15);
			texture_set_stage(sh_editorGridSurface_textureSkip, surface_get_texture(m_stencilBuffer));
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			drawShaderUnstore();
			gpu_pop_state();
		}
		// Create surface
		{
			surface_free_if_exists(m_stencilBuffer);
			m_stencilBuffer = surface_create_from_surface_params(Screen.m_gameSurface);
			surface_clear_color_alpha(m_stencilBuffer, c_black, 0.0);
			o_Camera3D.reapplyViewProjection(); // Needed since surface_sets set up their own projection.
		}
		matrix_set(matrix_world, mat_object_old);
	};
}
