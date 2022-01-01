function AEditorGizmoBase() constructor
{
	Cleanup = function() {};
	Step = function() {};
	Draw = function() {};
	
	MeshbAddColorArrow = function(mesh, color, width, length, normal)
	{
		// Get the X and Y alternates to the normal
		var cross_x, cross_y;
		cross_x = normal.cross(new Vector3(1, 0, 0));
		if (cross_x.sqrMagnitude() <= KINDA_SMALL_NUMBER)
		{
			cross_y = normal.cross(new Vector3(0, 1, 0));
			cross_x = cross_y.cross(normal);
		}
		else
		{
			cross_y = cross_x.cross(normal);
		}
		cross_x.normalize();
		cross_y.normalize();
		
		// Add the X-alternate first
		meshb_AddQuad(mesh, [
			new MBVertex(
				cross_x.multiply(width),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				cross_x.multiply(width).add(normal.multiply(length)),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				cross_x.multiply(-width),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			new MBVertex(
				cross_x.multiply(-width).add(normal.multiply(length)),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			]);
		// Add the Y-alternate first
		meshb_AddQuad(mesh, [
			new MBVertex(
				cross_y.multiply(width),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				cross_y.multiply(width).add(normal.multiply(length)),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				cross_y.multiply(-width),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			new MBVertex(
				cross_y.multiply(-width).add(normal.multiply(length)),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			]);
	}
}

function AEditorGizmoAxes() : AEditorGizmoBase() constructor
{
	var kBorderExpand = 10;
	var kAxisLength = 64;
	
	m_mesh = meshb_Begin();
		MeshbAddColorArrow(m_mesh, c_red, kBorderExpand, kAxisLength, new Vector3(1, 0, 0));
		MeshbAddColorArrow(m_mesh, c_lime, kBorderExpand, kAxisLength, new Vector3(0, 1, 0));
		MeshbAddColorArrow(m_mesh, c_blue, kBorderExpand, kAxisLength, new Vector3(0, 0, 1));
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
		var last_shader = drawShaderGet();
		var last_ztest = gpu_get_zfunc();
		var last_zwrite = gpu_get_zwriteenable();
			
		gpu_set_zwriteenable(false);
			
		drawShaderSet(sh_editorLineEdge);
		shader_set_uniform_f(global.m_editorLineEdge_uLineSizeAndFade, 1.0, 0, 0, 0);
			
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

/// @function AEditorGizmoSelectBox() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmoSelectBox() : AEditorGizmoBase() constructor
{
	m_visible = false;
	m_min = new Vector3();
	m_max = new Vector3();
	
	m_mesh = meshb_Begin();
	meshb_End(m_mesh); // Start with an empty mesh for now
	
	was_visible = false;
	
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
		}
	};
}

function EditorGizmoSetup()
{
	global.m_editorLineEdge_uLineColor = shader_get_uniform(sh_editorLineEdge, "uLineColor");
	global.m_editorLineEdge_uLineSizeAndFade = shader_get_uniform(sh_editorLineEdge, "uLineSizeAndFade");
	
	m_gizmoObject = inew(ob_3DObject);
	m_gizmoObject.translucent = false;
	m_gizmoObject.lit = false;

	with (m_gizmoObject)
	{
		m_axes = new AEditorGizmoAxes();
		m_select = new AEditorGizmoSelectBox();
	}
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.
		depth = 0;
		
		draw_set_color(c_white);
		draw_rectangle(16, 16, 32, 32, true);
		draw_rectangle(-16, 16, -32, 32, true);
		draw_rectangle(16, -16, 32, -32, true);
		draw_rectangle(-16, -16, -32, -32, true);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(f_Oxygen7);
		draw_text(32+4, 16, "+x");
		draw_text(16, 32+4, "+y");
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(-32-4, -16, "-x");
		draw_text(-16, -32-4, "-y");
		
		draw_circle(toolFlatX, toolFlatY, 4, true);
		draw_rectangle(toolTileX * 16, toolTileY * 16, toolTileX * 16 + 16, toolTileY * 16 + 16, true);
		
		m_gizmoObject.m_axes.Draw();
		m_gizmoObject.m_select.Draw();
	}
}

function EditorGizmoUpdate()
{
	/*var pixelX = uPosition - GameCamera.view_x;
	var pixelY = vPosition - GameCamera.view_y;
	
	var viewRayPos = [o_Camera3D.x, o_Camera3D.y, o_Camera3D.z];
	var viewRayDir = o_Camera3D.viewToRay(pixelX, pixelY);
	
	var distT = abs(viewRayPos[2] / viewRayDir[2]);
	
	toolFlatX = viewRayPos[0] + viewRayDir[0] * distT;
	toolFlatY = viewRayPos[1] + viewRayDir[1] * distT;
	
	toolTileX = max(0, floor(toolFlatX / 16));
	toolTileY = max(0, floor(toolFlatY / 16));*/
	
	with (m_gizmoObject)
	{
		m_select.Step();
	}
}
