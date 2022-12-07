/// @function AEditorGizmo3DEditBox() constructor
/// @desc Editor gizmo for the selection box.
function AEditorGizmo3DEditBox() : AEditorGizmoSelectBox3D() constructor // AEditorGizmoFlatGridCursorBox() constructor
{
	m_hasAnnotations = false;
	m_editAnnotations = [];
	
	m_editWantsCommit = false;
	m_editWantsCutout = false;
	m_editIsEditing = false;
	
	m_handlesActive = true;
	
	m_editDragIndex = null;
	m_editDragStart = new Vector3();
	m_editMinStart = new Vector3();
	m_editMaxStart = new Vector3();
	
	kDragBoxIndex = 13;
	
	m_color = c_yellow;
	static kColor = c_white;
	static kAlpha = 0.8; // Make more opaque than selection boxes.
	
	static kAnnotationDragXMin = 0;
	static kAnnotationDragXMax = 1;
	static kAnnotationDragYMin = 2;
	static kAnnotationDragYMax = 3;
	static kAnnotationDragZMin = 7;
	static kAnnotationDragZMax = 8;
	
	static kAnnotationLabelY = 4;
	static kAnnotationLabelX = 5;
	static kAnnotationLabelZ = 6;
	
	static kAnnotationButtonAdd = 9;
	static kAnnotationButtonSubtract = 10;
	
	OnEnable = function()
	{
		if (!m_hasAnnotations)
		{
			m_hasAnnotations = true;
				
			// Set up all initial annotaitons
			for (var i = 0; i < 11; ++i)
			{
				m_editAnnotations[i] = m_editor.AnnotationCreate();
				m_editAnnotations[i].m_icon = suie_annoteEdit;
				m_editAnnotations[i].m_iconIndex = 7;
				m_editAnnotations[i].m_canClick = true;
				m_editAnnotations[i].m_is3D = true;
			}
				
			// Set up the up and down annotations:
				
			m_editAnnotations[7].m_iconIndex = 4;
			m_editAnnotations[8].m_iconIndex = 5;
				
			// Set up size annotations:
	
			m_editAnnotations[4].m_icon = null;
			m_editAnnotations[4].m_canClick = false;
			m_editAnnotations[4].m_color = c_midgreen;
			m_editAnnotations[4].m_textOutline = true;
			m_editAnnotations[5].m_icon = null;
			m_editAnnotations[5].m_canClick = false;
			m_editAnnotations[5].m_color = c_red;
			m_editAnnotations[5].m_textOutline = true;
			m_editAnnotations[6].m_icon = null;
			m_editAnnotations[6].m_canClick = false;
			m_editAnnotations[6].m_color = c_midblue;
			m_editAnnotations[6].m_textOutline = true;
				
			// Set up the commit annotation:
				
			m_editAnnotations[9].m_iconIndex = 3;
			m_editAnnotations[9].m_text = "Create"
			m_editAnnotations[10].m_iconIndex = 6;
			m_editAnnotations[10].m_text = "Cutout"
		}
	}
	OnDisable = function()
	{
		// Clear drag index and other states
		m_editDragIndex = null;
		m_editWantsCommit = false;
		m_editWantsCutout = false;
		m_editIsEditing = false;
		
		// Destroy all annotations we have.
		if (m_hasAnnotations)
		{
			m_hasAnnotations = false;
				
			for (var i = 0; i < array_length(m_editAnnotations); ++i)
			{
				m_editor.AnnotationDestroy(m_editAnnotations[i]);
			}
			m_editAnnotations = [];
		}
	}
	
	static PointDirection2D = function(pointA, pointB)
	{
		var flatPointA = o_Camera3D.positionToView(pointA[0], pointA[1], pointA[2]);
		var flatPointB = o_Camera3D.positionToView(pointB[0], pointB[1], pointB[2]);
		return point_direction(flatPointA[0], flatPointA[1], flatPointB[0], flatPointB[1]);
	}
	static PointDistanceSqr2D = function(pointA, pointB)
	{
		var flatPointA = o_Camera3D.positionToView(pointA[0], pointA[1], pointA[2]);
		var flatPointB = o_Camera3D.positionToView(pointB[0], pointB[1], pointB[2]);
		return sqr(flatPointA[0] - flatPointB[0]) + sqr(flatPointA[1] - flatPointB[1]);
	}
	
	parent_Step = Step;
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_hasAnnotations)
		{
			var kEdgeMargin = 4;
			var kEdgeMarginInfo = 0; // Was 16, want more compact view.
			
			for (var i = 0; i < 10; ++i)
			{
				m_editAnnotations[i].m_is3D = true;
				m_editAnnotations[i].m_position = [
					(m_min.x + m_max.x) * 0.5,
					(m_min.y + m_max.y) * 0.5,
					(m_min.z + m_max.z) * 0.5];
			}
			
			// Set the edge arrows:
			
			m_editAnnotations[0].m_position[0] = m_min.x - kEdgeMargin;
			m_editAnnotations[1].m_position[0] = m_max.x + kEdgeMargin;
			m_editAnnotations[2].m_position[1] = m_min.y - kEdgeMargin;
			m_editAnnotations[3].m_position[1] = m_max.y + kEdgeMargin;
			// Set up the edge arrow angles as well!
			m_editAnnotations[0].m_iconAngle = PointDirection2D(m_editAnnotations[0].m_position, [m_editAnnotations[0].m_position[0] - 1, m_editAnnotations[0].m_position[1], m_editAnnotations[0].m_position[2]]);
			m_editAnnotations[1].m_iconAngle = PointDirection2D(m_editAnnotations[1].m_position, [m_editAnnotations[1].m_position[0] + 1, m_editAnnotations[1].m_position[1], m_editAnnotations[1].m_position[2]]);
			m_editAnnotations[2].m_iconAngle = PointDirection2D(m_editAnnotations[2].m_position, [m_editAnnotations[2].m_position[0], m_editAnnotations[2].m_position[1] - 1, m_editAnnotations[2].m_position[2]]);
			m_editAnnotations[3].m_iconAngle = PointDirection2D(m_editAnnotations[3].m_position, [m_editAnnotations[3].m_position[0], m_editAnnotations[3].m_position[1] + 1, m_editAnnotations[3].m_position[2]]);
			
			// Set up the up and down annotations:
			
			m_editAnnotations[7].m_position[2] = m_min.z - kEdgeMargin;
			m_editAnnotations[8].m_position[2] = m_max.z + kEdgeMargin;
			
			// Annotations for size:
			{
				// Choose edges based on the normals
				var camera_dir = Vector3FromArray(o_Camera3D.m_viewForward);
				var x_direction = camera_dir.dot(new Vector3(1, 0, 0));
				var y_direction = camera_dir.dot(new Vector3(0, 1, 0));
				var z_direction = camera_dir.dot(new Vector3(0, 0, 1));
				
				m_editAnnotations[4].m_position[0] = ((x_direction > 0.0) ? m_min.x : m_max.x) - kEdgeMarginInfo;
				m_editAnnotations[4].m_position[2] = (x_direction * z_direction > 0.0) ? m_min.z : m_max.z;
				m_editAnnotations[4].m_text = "Y " + string(round(abs(m_max.y - m_min.y)));
			
				m_editAnnotations[5].m_position[1] = ((y_direction > 0.0) ? m_min.y : m_max.y) - kEdgeMarginInfo;
				m_editAnnotations[5].m_position[2] = (y_direction * z_direction > 0.0) ? m_min.z : m_max.z;
				m_editAnnotations[5].m_text = "X " + string(round(abs(m_max.x - m_min.x)));
			
				m_editAnnotations[6].m_position[0] = ((x_direction > 0.0) ? m_min.x : m_max.x) - kEdgeMarginInfo;
				m_editAnnotations[6].m_position[1] = ((y_direction > 0.0) ? m_min.y : m_max.y) - kEdgeMarginInfo;
				m_editAnnotations[6].m_text = "Z " + string(round(abs(m_max.z - m_min.z)));
			}
			
			// Set up the commit annotation:
			
			m_editAnnotations[9].m_position[0] = m_max.x + kEdgeMargin;
			m_editAnnotations[9].m_position[1] = m_max.y + kEdgeMargin;
			m_editAnnotations[9].m_position[2] = m_min.z + kEdgeMargin * 2;
			
			m_editAnnotations[10].m_position[0] = m_min.x - kEdgeMargin;
			m_editAnnotations[10].m_position[1] = m_max.y + kEdgeMargin;
			m_editAnnotations[10].m_position[2] = m_min.z + kEdgeMargin * 2;
			
			// Check for overlapping annotations:
			{
				if (PointDistanceSqr2D(m_editAnnotations[7].m_position, m_editAnnotations[8].m_position) < sqr(10))
				{
					m_editAnnotations[7].m_position = o_Camera3D.positionToView(m_editAnnotations[7].m_position[0], m_editAnnotations[7].m_position[1], m_editAnnotations[7].m_position[2]);
					m_editAnnotations[8].m_position = o_Camera3D.positionToView(m_editAnnotations[8].m_position[0], m_editAnnotations[8].m_position[1], m_editAnnotations[8].m_position[2]);
					m_editAnnotations[7].m_is3D = false;
					m_editAnnotations[8].m_is3D = false;
					m_editAnnotations[7].m_position[1] += 5;
					m_editAnnotations[8].m_position[1] -= 5;
				}
			}
			
			// Update the actions based on clicks:
			
			if (m_handlesActive)
			{
				// Commit clicked?
				if (m_editAnnotations[9].click_state == kEditorToolButtonStateMake)
				{
					m_editWantsCommit = true;
				}
				else
				{
					m_editWantsCommit = false;
				}
				
				if (m_editAnnotations[10].click_state == kEditorToolButtonStateMake)
				{
					m_editWantsCutout = true;
				}
				else
				{
					m_editWantsCutout = false;
				}
			
				// Beginning to drag an edge?
				var edge_indices = [0, 1, 2, 3, 7, 8];
				for (var i = 0; i < array_length(edge_indices); ++i)
				{
					var edge_index = edge_indices[i];
					if (m_editAnnotations[edge_index].mouse_inside)
					{
						m_editor.uiNextCursor = kEditorUICursorHSize;
					}
					if (m_editAnnotations[edge_index].click_state == kEditorToolButtonStateMake)
					{
						m_editDragIndex = edge_index;
						m_editDragStart.x = m_editor.viewrayPixel[0];
						m_editDragStart.y = m_editor.viewrayPixel[1];
						m_editDragStart.z = m_editor.viewrayPixel[2];
						m_editMinStart.copyFrom(m_min);
						m_editMaxStart.copyFrom(m_max);
						break;
					}
				}
				// Check if we have mouse over the volume of our gizmo.
				if (m_editDragIndex == null)
				{
					if (raycast4_box(m_min, m_max, new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z), Vector3FromArray(m_editor.viewrayPixel)))
					{
						// Update cursor
						if (m_editor.uiNextCursor == kEditorUICursorNormal)
						{
							m_editor.uiNextCursor = kEditorUICursorMove;
						}
						// Check for click on the volume.
						if (MouseCheckButtonPressed(mb_left))
						{
							m_editDragIndex = kDragBoxIndex;
							m_editDragStart.x = m_editor.viewrayPixel[0];
							m_editDragStart.y = m_editor.viewrayPixel[1];
							m_editDragStart.z = m_editor.viewrayPixel[2];
							m_editMinStart.copyFrom(m_min);
							m_editMaxStart.copyFrom(m_max);
						}
					}
				}
			
				// Stop dragging when mouse is released.
				if (MouseCheckButtonReleased(mb_left))
				{
					m_editDragIndex = null;
				}
			
				// If draging an edge, let's mod the distances:
				if (m_editDragIndex != null)
				{
					m_min.copyFrom(m_editMinStart);
					m_max.copyFrom(m_editMaxStart);
					
					var bLocalSnap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
				
					var kScreensizeFactor = CalculateScreensizeFactor();
					// TODO: Project these rays onto the working plane
					var dragDelta = m_editDragStart.subtract(new Vector3(m_editor.viewrayPixel[0], m_editor.viewrayPixel[1], m_editor.viewrayPixel[2]));
					dragDelta.multiplySelf(1200 * kScreensizeFactor);
				
					if (m_editDragIndex == 0)
					{
						m_min.x -= dragDelta.x;
						m_min.x = !bLocalSnap ? m_min.x : round_nearest(m_min.x, m_editor.toolGridSize); 
					}
					else if (m_editDragIndex == 1)
					{
						m_max.x -= dragDelta.x;
						m_max.x = !bLocalSnap ? m_max.x : round_nearest(m_max.x, m_editor.toolGridSize); 
					}
					
					else if (m_editDragIndex == 2)
					{
						m_min.y -= dragDelta.y;
						m_min.y = !bLocalSnap ? m_min.y : round_nearest(m_min.y, m_editor.toolGridSize); 
					}
					else if (m_editDragIndex == 3)
					{
						m_max.y -= dragDelta.y;
						m_max.y = !bLocalSnap ? m_max.y : round_nearest(m_max.y, m_editor.toolGridSize); 
					}
					
					else if (m_editDragIndex == 7)
					{
						m_min.z -= dragDelta.z;
						m_min.z = !bLocalSnap ? m_min.z : round_nearest(m_min.z, m_editor.toolGridSize); 
					}
					else if (m_editDragIndex == 8)
					{
						m_max.z -= dragDelta.z;
						m_max.z = !bLocalSnap ? m_max.z : round_nearest(m_max.z, m_editor.toolGridSize); 
					}
					
					else if (m_editDragIndex == kDragBoxIndex)
					{
						m_min.x -= !bLocalSnap ? dragDelta.x : round_nearest(dragDelta.x, m_editor.toolGridSize);
						m_max.x -= !bLocalSnap ? dragDelta.x : round_nearest(dragDelta.x, m_editor.toolGridSize);
					
						m_min.y -= !bLocalSnap ? dragDelta.y : round_nearest(dragDelta.y, m_editor.toolGridSize);
						m_max.y -= !bLocalSnap ? dragDelta.y : round_nearest(dragDelta.y, m_editor.toolGridSize);
					}
					
					// Update cursor as well
					if (m_editDragIndex != kDragBoxIndex)
						m_editor.uiNextCursor = kEditorUICursorHSize;
					else
						m_editor.uiNextCursor = kEditorUICursorMove;
				}
			}
			
			// Update editing state
			m_editIsEditing = (m_editDragIndex != null);
		}
		
		parent_Step();
	}
	
	parent_Draw = Draw;
	/// @function Draw
	Draw = function()
	{
		/*if (m_visible)
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
		*/
		
		if (m_visible)
		{
			static sh_editorGridSurface_uGridInfo = shader_get_uniform(sh_editorGridSurface, "uGridInfo");
			
			drawShaderStore();
			gpu_push_state();
			
			gpu_set_zwriteenable(false);
			gpu_set_cullmode(cull_counterclockwise);
			
			drawShaderSet(sh_editorGridSurface);
			shader_set_uniform_f(sh_editorGridSurface_uGridInfo, m_editor.toolGridSize, m_editor.toolGridSize * 8.0, 0, 0);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
			
			drawShaderUnstore();
			gpu_pop_state();
		}
		
		parent_Draw();
	};
}