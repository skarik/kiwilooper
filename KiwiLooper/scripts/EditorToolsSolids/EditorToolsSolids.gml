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
			if (button == mb_left && buttonState == kEditorToolButtonStateMake)
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
			if (button == mb_left && buttonState == kEditorToolButtonStateBreak)
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
		
		m_editor.m_statusbar.m_toolHelpText = "Click-drag to create a ghost. Enter to change ghost to tiles. Alt-Enter to use ghost to subtract.";
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
	};
	onStep = function()
	{
		m_skipFrame = false;
		
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
			
			m_tileMin.x = floor(min(m_dragPositionStart.x, m_dragPositionEnd.x) / 16.0);
			m_tileMin.y = floor(min(m_dragPositionStart.y, m_dragPositionEnd.y) / 16.0);
			m_tileMin.z = floor(min(m_dragPositionStart.z, m_dragPositionEnd.z) / 16.0);
			
			m_tileMax.x = floor(max(m_dragPositionStart.x, m_dragPositionEnd.x) / 16.0);
			m_tileMax.y = floor(max(m_dragPositionStart.y, m_dragPositionEnd.y) / 16.0);
			m_tileMax.z = floor(max(m_dragPositionStart.z, m_dragPositionEnd.z) / 16.0);
			
			m_gizmo.m_min.copyFrom(m_tileMin.multiply(16));
			m_gizmo.m_max.copyFrom(m_tileMax.multiply(16).add(new Vector3(16, 16, 0)));
		}
		// Shaping state:
		else
		{
			m_gizmo.m_handlesActive = true;
			
			// Pull the min/max values from the gizmo.
			{
				m_tileMin.x = round(min(m_gizmo.m_min.x, m_gizmo.m_max.x - 16) / 16.0);
				m_tileMin.y = round(min(m_gizmo.m_min.y, m_gizmo.m_max.y - 16) / 16.0);
				m_tileMin.z = round(min(m_gizmo.m_min.z, m_gizmo.m_max.z) / 16.0);
			
				m_tileMax.x = round(max(m_gizmo.m_min.x, m_gizmo.m_max.x - 16) / 16.0);
				m_tileMax.y = round(max(m_gizmo.m_min.y, m_gizmo.m_max.y - 16) / 16.0);
				m_tileMax.z = round(max(m_gizmo.m_min.z, m_gizmo.m_max.z) / 16.0);
			
				m_gizmo.m_min.copyFrom(m_tileMin.multiply(16));
				m_gizmo.m_max.copyFrom(m_tileMax.multiply(16).add(new Vector3(16, 16, 0)));
			}
			
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
				
				array_push(map.solids, newSolid);
				
				m_editor.MapRebuildSolidsOnly();
				
				// TODO
				
				/*with (m_editor)
				{
					var kInputHeight = other.m_tileMax.z;
					
					if (kInputHeight < 0) continue; // Skip sub-zero layers since the mesher will crash
					
					for (var ix = other.m_tileMin.x; ix <= other.m_tileMax.x; ++ix)
					{
						for (var iy = other.m_tileMin.y; iy <= other.m_tileMax.y; ++iy)
						{
							var existingTile = m_tilemap.GetPosition(ix, iy);
							// create a new block at position if it doesn't exist yet
							if (!is_struct(existingTile))
							{
								var maptile = new AMapTile();
								maptile.x = ix;
								maptile.y = iy;
								maptile.height = kInputHeight;
								
								m_tilemap.AddTile(maptile);
							}
							// otherwise, heighten the block if it's lower than the gizmo height
							else
							{
								if (existingTile.height < kInputHeight)
								{
									m_tilemap.RemoveHeightSlow(existingTile.height); // TODO: defer this.
									existingTile.height = kInputHeight;
								}
							}
						}
					}
					
					m_tilemap.AddHeight(kInputHeight);
					MapRebuildGraphics();
				}*/
				
			}
			
			// Check for building the map up
			/*if ((keyboard_check_pressed(vk_enter) && keyboard_check(vk_alt))
				|| m_gizmo.m_editWantsCutout)
			{
				m_isDraggingShape = false;
				m_hasShapeReady = false;
				m_skipFrame = true; // Skip the next click event. TODO: make this a common call.
				
				// TODO.
				
				with (m_editor)
				{
					var kInputHeight = other.m_tileMin.z;
					
					for (var ix = other.m_tileMin.x; ix <= other.m_tileMax.x; ++ix)
					{
						for (var iy = other.m_tileMin.y; iy <= other.m_tileMax.y; ++iy)
						{
							var existingTileIndex = m_tilemap.GetPositionIndex(ix, iy);
							
							if (existingTileIndex >= 0)
							{
								var existingTile = m_tilemap.tiles[existingTileIndex];
								
								// lower the height of the tile if the input height is high enough
								if (kInputHeight >= 0)
								{
									if (existingTile.height > kInputHeight)
									{
										m_tilemap.RemoveHeightSlow(existingTile.height); // TODO: defer this.
										existingTile.height = kInputHeight;
									}
								}
								// otherwise, we delete the tile
								else
								{
									m_tilemap.RemoveHeightSlow(existingTile.height);
									m_tilemap.DeleteTileIndex(existingTileIndex); // TODO: defer this.
								}
							}
						}
					}
					
					if (kInputHeight >= 0)
						m_tilemap.AddHeight(kInputHeight);
					MapRebuildGraphics();
				}
				
			}*/
		}
		
	};
}