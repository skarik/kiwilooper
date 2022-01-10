/// @function AEditorGizmoSelectBox() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoSelectBox() : AEditorGizmoBase() constructor
{
	m_visible = false;
	m_min = new Vector3();
	m_max = new Vector3();
	m_color = c_white;
	m_alpha = 1.0;
	
	m_mesh = meshb_Begin();
	meshb_End(m_mesh); // Start with an empty mesh for now
	
	was_visible = false;
	
	AddSquare = function(kBorderExpand)
	{
		gml_pragma("forceinline");
		
		var kUVBumpX = kBorderExpand / (m_max.x - m_min.x);
		var kUVBumpY = kBorderExpand / (m_max.y - m_min.y);
			
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_min.y - kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_min.y - kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_max.y + kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_max.y + kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			)
			]);
	}
	
	/// @function Cleanup()
	/// @desc Cleans up the mesh used for rendering.
	Cleanup = function()
	{
		meshB_Cleanup(m_mesh);
	};
	
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_visible)
		{
			var kBorderExpand = 2 / max(0.0001, abs(lengthdir_y(1, o_Camera3D.yrotation)));
			var kUVBumpX = kBorderExpand / (m_max.x - m_min.x);
			var kUVBumpY = kBorderExpand / (m_max.y - m_min.y);
			
			meshb_BeginEdit(m_mesh);
				AddSquare(kBorderExpand);
			meshb_End(m_mesh);
			
			was_visible = true;
		}
		else if (was_visible)
		{
			was_visible = false;
			meshb_BeginEdit(m_mesh);
			meshb_End(m_mesh);
		}
	};
	
	/// @function Draw
	Draw = function()
	{
		if (m_visible)
		{
			var last_shader = drawShaderGet();
			var last_ztest = gpu_get_zfunc();
			var last_zwrite = gpu_get_zwriteenable();
			
			var color_r = color_get_red(m_color) / 255.0;
			var color_g = color_get_green(m_color) / 255.0;
			var color_b = color_get_blue(m_color) / 255.0;
			
			gpu_set_zwriteenable(false);
			
			drawShaderSet(sh_editorLineEdge);
			shader_set_uniform_f(global.m_editorLineEdge_uLineSizeAndFade, 0.5, 0, 0, 0);
			
			gpu_set_zfunc(cmpfunc_greater);
			shader_set_uniform_f(global.m_editorLineEdge_uLineColor, color_r * 0.5, color_g * 0.5, color_b * 0.5, m_alpha);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			gpu_set_zfunc(last_ztest);
			shader_set_uniform_f(global.m_editorLineEdge_uLineColor, color_r, color_g, color_b, m_alpha);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			drawShaderSet(last_shader);
			gpu_set_zwriteenable(last_zwrite);
		}
	};
}

/// @function AEditorGizmoFlatGridCursorBox() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoFlatGridCursorBox() : AEditorGizmoSelectBox() constructor
{
}

/// @function AEditorGizmoSelectBox3D() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoSelectBox3D() : AEditorGizmoSelectBox() constructor
{
	AddCube = function(kBorderExpand)
	{
		gml_pragma("forceinline");
		
		var kUVBumpX = kBorderExpand / (m_max.x - m_min.x);
		var kUVBumpY = kBorderExpand / (m_max.y - m_min.y);
		var kUVBumpZ = kBorderExpand / (m_max.z - m_min.z);
		
		// Z faces:
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_min.y - kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_min.y - kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_max.y + kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_max.y + kBorderExpand, m_min.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			)
			]);
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_min.y - kBorderExpand, m_max.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_min.y - kBorderExpand, m_max.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 0.0 - kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_max.y + kBorderExpand, m_max.z),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_max.y + kBorderExpand, m_max.z),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 1.0 + kUVBumpY)),
				new Vector3(0, 0, 1)
			)
			]);
				
		// X faces:
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x, m_min.y - kBorderExpand, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpY, 0.0 - kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_min.x, m_max.y + kBorderExpand, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpY, 0.0 - kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_min.x, m_min.y - kBorderExpand, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpY, 1.0 + kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_min.x, m_max.y + kBorderExpand, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpY, 1.0 + kUVBumpZ)),
				new Vector3(1, 0, 0)
			)
			]);
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_max.x, m_min.y - kBorderExpand, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpY, 0.0 - kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_max.x, m_max.y + kBorderExpand, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpY, 0.0 - kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_max.x, m_min.y - kBorderExpand, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpY, 1.0 + kUVBumpZ)),
				new Vector3(1, 0, 0)
			),
			new MBVertex(
				new Vector3(m_max.x, m_max.y + kBorderExpand, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpY, 1.0 + kUVBumpZ)),
				new Vector3(1, 0, 0)
			)
			]);
				
		// Y faces:
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_min.y, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 0.0 - kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_min.y, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 0.0 - kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_min.y, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 1.0 + kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_min.y, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 1.0 + kUVBumpZ)),
				new Vector3(0, 1, 0)
			)
			]);
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_max.y, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 0.0 - kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_max.y, m_min.z - kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 0.0 - kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_min.x - kBorderExpand, m_max.y, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(0.0 - kUVBumpX, 1.0 + kUVBumpZ)),
				new Vector3(0, 1, 0)
			),
			new MBVertex(
				new Vector3(m_max.x + kBorderExpand, m_max.y, m_max.z + kBorderExpand),
				c_white, 1.0,
				(new Vector2(1.0 + kUVBumpX, 1.0 + kUVBumpZ)),
				new Vector3(0, 1, 0)
			)
			]);
	}
	
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_visible)
		{
			var kBorderExpand = 2 / max(0.0001, abs(lengthdir_y(1, o_Camera3D.yrotation)));
			
			meshb_BeginEdit(m_mesh);
				if (abs(m_min.z - m_max.z) > 1)
				{
					AddCube(kBorderExpand);
				}
				else
				{
					AddSquare(kBorderExpand);
				}
			meshb_End(m_mesh);
			
			was_visible = true;
		}
		else if (was_visible)
		{
			was_visible = false;
			meshb_BeginEdit(m_mesh);
			meshb_End(m_mesh);
		}
	};
}

/// @function AEditorGizmoMultiSelectBox3D() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoMultiSelectBox3D() : AEditorGizmoSelectBox3D() constructor
{
	m_mins = [];
	m_maxes = [];
	
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_visible)
		{
			assert(array_length(m_mins) == array_length(m_maxes));
		
			var kBorderExpand = 2 / max(0.0001, abs(lengthdir_y(1, o_Camera3D.yrotation)));
		
			meshb_BeginEdit(m_mesh);
				for (var i = 0; i < array_length(m_mins); ++i)
				{
					m_min = m_mins[i];
					m_max = m_maxes[i];
					AddCube(kBorderExpand);
				}
			meshb_End(m_mesh);
		}
		else if (was_visible)
		{
			was_visible = false;
			meshb_BeginEdit(m_mesh);
			meshb_End(m_mesh);
		}
	}
}