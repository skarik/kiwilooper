function EditorGizmoSetup()
{
	global.m_editorLineEdge_uLineColor = shader_get_uniform(sh_editorLineEdge, "uLineColor");
	global.m_editorLineEdge_uLineSizeAndFade = shader_get_uniform(sh_editorLineEdge, "uLineSizeAndFade");
	
	global.m_editorFlatShaded_uFlatColor = shader_get_uniform(sh_editorFlatShaded, "uFlatColor");
	
	m_entList = [
		// type, sprite, index, hullsize
		[ob_3DLight, suie_gizmoEnts, 0, 8],
		[o_ambientOverride, suie_gizmoEnts, 1, 8],
		[o_livelyDoor, suie_gizmoEnts, 5, 8],
		];
	
	m_selection = [];
	m_selectionSingle = true;
	
	m_gizmoObject = inew(ob_3DObject);
	m_gizmoObject.translucent = false;
	m_gizmoObject.lit = false;
	
	/*m_gizmoFactories = [
		[kEditorGizmoNone,	null],
		[kEditorGizmoAxes,	AEditorGizmoAxes],
		[kEditorGizmoAxesMove,	AEditorGizmoAxesMove],
	];*/
	m_gizmoInstances = [];
	
	/// @function EditorGizmoGet(factory)
	/// @desc Grabs existing or instantiates the given gizmo object.
	EditorGizmoGet = function(factory)
	{
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			if (m_gizmoInstances[instanceIndex][0] == factory)
			{
				return m_gizmoInstances[instanceIndex][1];
			}
		}
	
		var gizmoInstance = new factory();
		array_push(m_gizmoInstances, [factory, gizmoInstance]);
		return gizmoInstance;
	}

	with (m_gizmoObject)
	{
		//m_axes = new AEditorGizmoAxes();
		m_axes = other.EditorGizmoGet(AEditorGizmoAxes);
		//m_select = new AEditorGizmoSelectBox();
		// need a move gizmo (x, y, z)
		//m_mover = new AEditorGizmoPointMove();
		//m_movertest = new AEditorGizmoAxesMove();
		
		m_entRenderers = other.EditorGizmoGet(AEditorGizmoEntityBillboards);
	}
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.
		depth = 0;
		
		/*draw_set_color(c_white);
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
		draw_rectangle(toolTileX * 16, toolTileY * 16, toolTileX * 16 + 16, toolTileY * 16 + 16, true);*/
		
		//m_gizmoObject.m_axes.Draw();
		//m_gizmoObject.m_select.Draw();
		//m_gizmoObject.m_mover.Draw();
		//m_gizmoObject.m_movertest.Draw();
		for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
		{
			var gizmoInstance = m_gizmoInstances[instanceIndex][1];
			if (gizmoInstance.m_visible)
			{
				gizmoInstance.Draw();
			}
		}
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
		//m_select.Step();
		//m_mover.Step();
		//m_movertest.Step();
	}
	
	for (var instanceIndex = 0; instanceIndex < array_length(m_gizmoInstances); ++instanceIndex)
	{
		var gizmoInstance = m_gizmoInstances[instanceIndex][1];
		if (gizmoInstance.m_enabled)
		{
			gizmoInstance.Step();
		}
	}
}
