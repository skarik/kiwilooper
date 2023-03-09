/// @function AEditorToolStateMakeSolids() constructor
function AEditorToolStateMakeSolids() : AEditorToolState() constructor
{
	state = kEditorToolMakeSolids;
	
	m_hasShapeReady = false;
	m_isDraggingShape = false;
	m_skipFrame = false;
	
	m_dragPositionStart = new Vector3();
	m_dragPositionEnd = new Vector3();
	m_dragAxis = kAxisZ;
	
	m_tileMin = new Vector3();
	m_tileMax = new Vector3();
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (m_skipFrame)
		{
			return;
		}
		
		// Initial waiting for input:
		if (!m_hasShapeReady)
		{
			if (button == mb_left && (buttonState & kEditorToolButtonStateMake))
			{
				// Begin dragging:
				m_hasShapeReady = true;
				m_isDraggingShape = true;
				
				if (m_editor.toolWorldValid)
				{
					m_dragPositionStart.set(m_editor.toolWorldX, m_editor.toolWorldY, m_editor.toolWorldZ);
					m_dragAxis = rayutil4_getaxis(m_editor.toolWorldNormal);
					m_dragPositionStart.addSelf(m_editor.toolWorldNormal); // This fixes various rounding issues.
				}
				else
				{
					m_dragPositionStart.set(m_editor.toolFlatX, m_editor.toolFlatY, 0);
					m_dragAxis = kAxisZ;
				}
				
				m_dragPositionEnd.copyFrom(m_dragPositionStart);
			}
		}
		// Dragging state:
		else if (m_isDraggingShape)
		{
			if (button == mb_left && (buttonState & kEditorToolButtonStateBreak))
			{
				// On release, stop dragging.
				m_isDraggingShape = false;
			}
		}
		// Shaping state:
		else
		{
			// Nothing here.
		}
	};
	
	m_gizmo = null;
	
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmo3DEditBox);
		m_gizmo.SetVisible();
		m_gizmo.SetEnabled();
		m_gizmo.m_color = c_gold;
		m_gizmo.m_alpha = 0.75;
		
		m_editor.m_statusbar.m_toolHelpText = "Click-drag to create a ghost. Enter to make a solid. Alt-Enter to use ghost to subtract.";
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.SetInvisible();
			m_gizmo.SetDisabled();
		}
		
		// Disable the gizmo temporarily.
		m_gizmo.SetDisabled();
		
		m_editor.toolGridTemporaryDisable = false; // Reset states
	};
	onStep = function()
	{
		m_skipFrame = false;
		
		// Keyboard "no-snap" override toggle
		m_editor.toolGridTemporaryDisable = keyboard_check(vk_alt);
		// Check grid stuff
		var bLocalSnap = m_editor.toolGrid && !m_editor.toolGridTemporaryDisable;
		
		// Initial waiting for input:
		if (!m_hasShapeReady)
		{
			// Hide the gizmo.
			m_gizmo.SetInvisible();
			m_gizmo.SetDisabled();
			m_gizmo.m_handlesActive = false;
		}
		// Dragging state:
		else if (m_isDraggingShape)
		{
			// Update the gizmo.
			m_gizmo.SetVisible();
			m_gizmo.SetEnabled();
			m_gizmo.m_handlesActive = false;
			
			// Project the view position onto the current working plane
			var ray_position = new Vector3(o_Camera3D.x, o_Camera3D.y, o_Camera3D.z);
			var ray_dir = Vector3FromArray(m_editor.viewrayPixel);
			var force_xy = !keyboard_check(vk_alt);
			if (raycast4_axisplane(force_xy ? kAxisZ : m_dragAxis, m_dragPositionStart.getElement(force_xy ? kAxisZ : m_dragAxis), ray_position, ray_dir))
			{
				m_dragPositionEnd.copyFrom(ray_position.add(ray_dir.multiply(raycast4_get_hit_distance())));
			}
			
			if (bLocalSnap)
			{
				m_tileMin.x = floor(min(m_dragPositionStart.x, m_dragPositionEnd.x) / m_editor.toolGridSize);
				m_tileMin.y = floor(min(m_dragPositionStart.y, m_dragPositionEnd.y) / m_editor.toolGridSize);
				m_tileMin.z = floor(min(m_dragPositionStart.z, m_dragPositionEnd.z) / m_editor.toolGridSize);
			
				m_tileMax.x = floor(max(m_dragPositionStart.x, m_dragPositionEnd.x) / m_editor.toolGridSize);
				m_tileMax.y = floor(max(m_dragPositionStart.y, m_dragPositionEnd.y) / m_editor.toolGridSize);
				m_tileMax.z = floor(max(m_dragPositionStart.z, m_dragPositionEnd.z) / m_editor.toolGridSize);
			
				m_gizmo.m_min.copyFrom(m_tileMin.multiply(m_editor.toolGridSize));
				m_gizmo.m_max.copyFrom(m_tileMax.multiply(m_editor.toolGridSize).add(new Vector3(m_editor.toolGridSize, m_editor.toolGridSize, m_editor.toolGridSize)));
			}
		}
		// Shaping state:
		else
		{
			m_gizmo.m_handlesActive = true;
			
			// Pull the min/max values from the gizmo.
			m_tileMin.x = round(m_gizmo.m_min.x);
			m_tileMin.y = round(m_gizmo.m_min.y);
			m_tileMin.z = round(m_gizmo.m_min.z);
			
			m_tileMax.x = round(m_gizmo.m_max.x);
			m_tileMax.y = round(m_gizmo.m_max.y);
			m_tileMax.z = round(m_gizmo.m_max.z);
			
			// Check for cancel inputs.
			if (keyboard_check_pressed(vk_delete) || keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_backspace))
			{
				m_isDraggingShape = false;
				m_hasShapeReady = false;
			}
			
			// Check for building the map up
			if ((keyboard_check_pressed(vk_enter) && !keyboard_check(vk_alt))
				|| m_gizmo.m_editWantsCommit)
			{
				m_isDraggingShape = false;
				m_hasShapeReady = false;
				m_skipFrame = true; // Skip the next click event. TODO: make this a common call.
				
				// TODO.
				
				var map = m_editor.m_state.map;
				
				//map.solids
				var newSolid = new AMapSolid();
				
				newSolid.faces = array_create(6);
				newSolid.vertices = array_create(8);
				
				for (var i = 0; i < 8; ++i)
					newSolid.vertices[i] = new AMapSolidVertex();
				newSolid.vertices[0].position.copyFrom({x: m_gizmo.m_min.x, y: m_gizmo.m_min.y, z: m_gizmo.m_min.z});
				newSolid.vertices[1].position.copyFrom({x: m_gizmo.m_max.x, y: m_gizmo.m_min.y, z: m_gizmo.m_min.z});
				newSolid.vertices[2].position.copyFrom({x: m_gizmo.m_max.x, y: m_gizmo.m_max.y, z: m_gizmo.m_min.z});
				newSolid.vertices[3].position.copyFrom({x: m_gizmo.m_min.x, y: m_gizmo.m_max.y, z: m_gizmo.m_min.z});
				newSolid.vertices[4].position.copyFrom({x: m_gizmo.m_min.x, y: m_gizmo.m_min.y, z: m_gizmo.m_max.z});
				newSolid.vertices[5].position.copyFrom({x: m_gizmo.m_max.x, y: m_gizmo.m_min.y, z: m_gizmo.m_max.z});
				newSolid.vertices[6].position.copyFrom({x: m_gizmo.m_max.x, y: m_gizmo.m_max.y, z: m_gizmo.m_max.z});
				newSolid.vertices[7].position.copyFrom({x: m_gizmo.m_min.x, y: m_gizmo.m_max.y, z: m_gizmo.m_max.z});
				
				for (var i = 0; i < 6; ++i)
					newSolid.faces[i] = new AMapSolidFace();
				newSolid.faces[0].indicies = [3, 2, 1, 0];
				newSolid.faces[1].indicies = [4, 5, 6, 7];
				newSolid.faces[2].indicies = [0, 1, 5, 4];
				newSolid.faces[3].indicies = [2, 3, 7, 6];
				newSolid.faces[4].indicies = [1, 2, 6, 5];
				newSolid.faces[5].indicies = [3, 0, 4, 7];
				
				// TODO: fix the normals on all the faces
				// TODO: pull in call to the UV tool to world-map every face
				var texturing_tool = EditorToolGetInstance(kEditorToolTextureSolids);
				if (is_struct(texturing_tool))
				{
					var new_solid_face_selection = array_create(array_length(newSolid.faces));
					for (var i = 0; i < array_length(newSolid.faces); ++i)
					{
						new_solid_face_selection[i] = EditorSelectionWrapPrimitive(newSolid, i);
					}
					/*var params = {};
					texturing_tool.UV_ForEachFaceIn(undefined, new_solid_face_selection, params, function(mapSolid, face, params) 
					{
					});*/
					texturing_tool.UVAlignToWorld(new_solid_face_selection); // Also applies new normals
				}
				
				array_push(map.solids, newSolid);
				
				m_editor.MapRebuildSolidsOnly();
				
				EditorGlobalMarkDirtyGeometry();
			}
		}
		
	};
}