function AEditorGizmoBase() constructor
{
	m_editor = EditorGet(); // TODO: pass this in?

	x = 0;
	y = 0;
	z = 0;

	// Is this gizmo's render called? Toggle with SetVisible/SetInvisible.
	m_visible = true;
	// Is this gizmo's step called? Toggle with SetEnabled/SetDisabled.
	m_enabled = true;
	
	// Does this gizmo want release? If unused for a period of time, it will be freed from memory.
	wants_release = false;
	
	static SetVisible = function()
	{
		gml_pragma("forceinline");
		m_visible = true;
	};
	static SetInvisible = function()
	{
		gml_pragma("forceinline");
		m_visible = false;
	};
	static GetVisible = function()
	{
		gml_pragma("forceinline");
		return m_visible;
	};
	
	static SetEnabled = function()
	{
		gml_pragma("forceinline");
		if (!m_enabled)
		{
			m_enabled = true;
			OnEnable();
		}
	};
	static SetDisabled = function()
	{
		gml_pragma("forceinline");
		if (m_enabled)
		{
			m_enabled = false;
			OnDisable();
		}
	};
	static GetEnabled = function()
	{
		gml_pragma("forceinline");
		return m_enabled;
	};
	
	static Cleanup = function() {};
	static Step = function() {};
	static Draw = function() {};
	static OnEnable = function() {}; // TODO: Call these
	static OnDisable = function() {};
	
	GetConsumingMouse = function() { return false; }
	
	static _mouse = array_create(5, false);
	static _mousePressed = array_create(5, false);
	static _mouseReleased = array_create(5, false);
	static _mouseAvailable = true;
	static _MouseGetButtonIndex = function(button)
	{
		switch (button)
		{
		case mb_left:	return 0;
		case mb_right:	return 1;
		case mb_middle:	return 2;
		case kMouseWheelUp:	return 3;
		case kMouseWheelDown:	return 4;
		}
		return -1;
	}
	static MouseAvailable = function()
	{
		return _mouseAvailable;
	}
	static MouseCheckButton = function(button)
	{
		return _mouse[_MouseGetButtonIndex(button)];
	}
	static MouseCheckButtonPressed = function(button)
	{
		return _mousePressed[_MouseGetButtonIndex(button)];
	}
	static MouseCheckButtonReleased = function(button)
	{
		return _mouseReleased[_MouseGetButtonIndex(button)];
	}
	
	MeshbAddLine = function(mesh, color, width, length, normal, position)
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
				position.add(cross_x.multiply(width)),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(width).add(normal.multiply(length))),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(-width)),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(-width).add(normal.multiply(length))),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			]);
		// Add the Y-alternate first
		meshb_AddQuad(mesh, [
			new MBVertex(
				position.add(cross_y.multiply(width)),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				position.add(cross_y.multiply(width).add(normal.multiply(length))),
				color, 1.0,
				new Vector2(0.5, -0.5),
				normal),
			new MBVertex(
				position.add(cross_y.multiply(-width)),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			new MBVertex(
				position.add(cross_y.multiply(-width).add(normal.multiply(length))),
				color, 1.0,
				new Vector2(0.5, 0.5),
				normal),
			]);
	};
	
	MeshbAddBillboardTriangle = function(mesh, color, width, length, normal, position)
	{
		var frontface_direction = new Vector3(m_editor.viewrayForward[0], m_editor.viewrayForward[1], m_editor.viewrayForward[2]);
		var cross_x = frontface_direction.cross(normal);
		cross_x.normalize();
		
		meshb_PushVertex(mesh, new MBVertex(
			position.add(cross_x.multiply(width)),
			color, 1.0,
			new Vector2(0.0, 0.0),
			normal));
		meshb_PushVertex(mesh, new MBVertex(
			position.add(cross_x.multiply(-width)),
			color, 1.0,
			new Vector2(0.0, 1.0),
			normal));
		meshb_PushVertex(mesh, new MBVertex(
			position.add(normal.multiply(length)),
			color, 1.0,
			new Vector2(1.0, 0.5),
			normal));
	};
	
	MeshbAddBillboardUVs = function(mesh, color, width, height, uvs, normal, position)
	{
		var frontface_direction = new Vector3(m_editor.viewrayForward[0], m_editor.viewrayForward[1], m_editor.viewrayForward[2]);
		// TODO: just pull this data from the camera matrix Left and Up itself
		var cross_x = frontface_direction.cross(new Vector3(0, 0, 1));
		var cross_y = frontface_direction.cross(cross_x);
		cross_x.normalize().multiplySelf(width * 0.5);
		cross_y.normalize().multiplySelf(height * 0.5);
		
		meshb_AddQuad(mesh, [
			new MBVertex(
				position.add(cross_x.multiply(-1.0)).add(cross_y.multiply(-1.0)),
				color, 1.0,
				(new Vector2(0.0, 0.0)).biasUVSelf(uvs),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(1.0)).add(cross_y.multiply(-1.0)),
				color, 1.0,
				(new Vector2(1.0, 0.0)).biasUVSelf(uvs),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(-1.0)).add(cross_y.multiply(1.0)),
				color, 1.0,
				(new Vector2(0.0, 1.0)).biasUVSelf(uvs),
				normal),
			new MBVertex(
				position.add(cross_x.multiply(1.0)).add(cross_y.multiply(1.0)),
				color, 1.0,
				(new Vector2(1.0, 1.0)).biasUVSelf(uvs),
				normal),
				]);
	};
	
	MeshbAddQuad = function(mesh, color, xsize, ysize, position)
	{
		var normal = xsize.cross(ysize);
		normal.normalize();
		
		meshb_AddQuad(mesh, [
			new MBVertex(
				position,
				color, 1.0,
				new Vector2(0.0, 0.0),
				normal),
			new MBVertex(
				position.add(xsize),
				color, 1.0,
				new Vector2(1.0, 0.0),
				normal),
			new MBVertex(
				position.add(ysize),
				color, 1.0,
				new Vector2(0.0, 1.0),
				normal),
			new MBVertex(
				position.add(xsize).add(ysize),
				color, 1.0,
				new Vector2(1.0, 1.0),
				normal),
			]);
	};
	
	/// @function CalculateScreensizeFactor()
	/// @desc Calculates the screen scaling factor so that the item can remain roughly constant size at 360p
	CalculateScreensizeFactor = function()
	{
		var raylength = sqr(x - o_Camera3D.x) + sqr(y - o_Camera3D.y) + sqr(z - o_Camera3D.z);
		var screendelta = sqrt(raylength * (
			sqr(m_editor.viewrayTopLeft[0] - m_editor.viewrayBottomRight[0])
			+ sqr(m_editor.viewrayTopLeft[1] - m_editor.viewrayBottomRight[1])
			+ sqr(m_editor.viewrayTopLeft[2] - m_editor.viewrayBottomRight[2])));
			
		var size_factor = screendelta / 360;
		
		return size_factor;
	};
}

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