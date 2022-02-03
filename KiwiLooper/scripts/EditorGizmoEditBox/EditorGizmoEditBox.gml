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
				m_editAnnotations[i].m_iconIndex = 0;
				m_editAnnotations[i].m_canClick = true;
				m_editAnnotations[i].m_is3D = true;
			}
				
			// Set up the up and down annotations:
				
			m_editAnnotations[7].m_iconIndex = 4;
			m_editAnnotations[8].m_iconIndex = 5;
				
			// Set up size annotations:
	
			m_editAnnotations[4].m_icon = null;
			m_editAnnotations[4].m_canClick = false;
			m_editAnnotations[4].m_color = c_yellow;
			m_editAnnotations[5].m_icon = null;
			m_editAnnotations[5].m_canClick = false;
			m_editAnnotations[5].m_color = c_yellow;
			m_editAnnotations[6].m_icon = null;
			m_editAnnotations[6].m_canClick = false;
			m_editAnnotations[6].m_color = c_yellow;
				
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
	
	parent_Step = Step;
	/// @function Step()
	/// @desc Builds the mesh for the rendering.
	Step = function()
	{
		if (m_hasAnnotations)
		{
			var kEdgeMargin = 4;
			var kEdgeMarginInfo = 16;
			
			for (var i = 0; i < 10; ++i)
			{
				m_editAnnotations[i].m_position = [
					(m_min.x + m_max.x) * 0.5,
					(m_min.y + m_max.y) * 0.5,
					(m_min.z + m_max.z) * 0.5];
			}
			
			m_editAnnotations[0].m_position[0] = m_min.x - kEdgeMargin;
			m_editAnnotations[1].m_position[0] = m_max.x + kEdgeMargin;
			m_editAnnotations[2].m_position[1] = m_min.y - kEdgeMargin;
			m_editAnnotations[3].m_position[1] = m_max.y + kEdgeMargin;
			
			// Set up the up and down annotations:
			
			m_editAnnotations[7].m_position[2] = m_min.z - kEdgeMargin;
			m_editAnnotations[8].m_position[2] = m_max.z + kEdgeMargin;
			
			// Annotations for size:
			
			m_editAnnotations[4].m_position[0] = m_min.x - kEdgeMarginInfo;
			m_editAnnotations[4].m_position[2] = m_max.z;
			m_editAnnotations[4].m_text = "Y: " + string(abs(m_max.y - m_min.y));
			
			m_editAnnotations[5].m_position[1] = m_min.y - kEdgeMarginInfo;
			m_editAnnotations[5].m_position[2] = m_max.z;
			m_editAnnotations[5].m_text = "X: " + string(abs(m_max.x - m_min.x));
			
			m_editAnnotations[6].m_position[0] = m_min.x - kEdgeMargin;
			m_editAnnotations[6].m_position[1] = m_min.y - kEdgeMargin;
			m_editAnnotations[6].m_text = "Z: " + string(abs(m_max.z - m_min.z));
			
			// Set up the commit annotation:
			
			m_editAnnotations[9].m_position[0] = m_max.x + kEdgeMargin;
			m_editAnnotations[9].m_position[1] = m_max.y + kEdgeMargin;
			m_editAnnotations[9].m_position[2] = m_max.z + kEdgeMargin;
			
			m_editAnnotations[10].m_position[0] = m_min.x - kEdgeMargin;
			m_editAnnotations[10].m_position[1] = m_max.y + kEdgeMargin;
			m_editAnnotations[10].m_position[2] = m_max.z + kEdgeMargin;
			
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
						if (mouse_check_button_pressed(mb_left))
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
				if (mouse_check_button_released(mb_left))
				{
					m_editDragIndex = null;
				}
			
				// If draging an edge, let's mod the distances:
				if (m_editDragIndex != null)
				{
					m_min.copyFrom(m_editMinStart);
					m_max.copyFrom(m_editMaxStart);
				
					var kScreensizeFactor = CalculateScreensizeFactor();
					// TODO: Project these rays onto the working plane
					var dragDelta = m_editDragStart.subtract(new Vector3(m_editor.viewrayPixel[0], m_editor.viewrayPixel[1], m_editor.viewrayPixel[2]));
				
					if (m_editDragIndex == 0)
						m_min.x -= dragDelta.x * 1200 * kScreensizeFactor;
					else if (m_editDragIndex == 1)
						m_max.x -= dragDelta.x * 1200 * kScreensizeFactor;
					
					else if (m_editDragIndex == 2)
						m_min.y -= dragDelta.y * 1200 * kScreensizeFactor;
					else if (m_editDragIndex == 3)
						m_max.y -= dragDelta.y * 1200 * kScreensizeFactor;
					
					else if (m_editDragIndex == 7)
						m_min.z -= dragDelta.z * 1200 * kScreensizeFactor;
					else if (m_editDragIndex == 8)
						m_max.z -= dragDelta.z * 1200 * kScreensizeFactor;
					
					else if (m_editDragIndex == kDragBoxIndex)
					{
						m_min.x -= dragDelta.x * 1200 * kScreensizeFactor;
						m_max.x -= dragDelta.x * 1200 * kScreensizeFactor;
					
						m_min.y -= dragDelta.y * 1200 * kScreensizeFactor;
						m_max.y -= dragDelta.y * 1200 * kScreensizeFactor;
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
}