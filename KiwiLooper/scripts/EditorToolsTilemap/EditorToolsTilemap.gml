/// @function AEditorToolStateTileEditor() constructor
function AEditorToolStateTileEditor() : AEditorToolState() constructor
{
	state = kEditorToolTileEditor;
	
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
		//m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoFlatGridCursorBox);
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmo3DEditBox);
		m_gizmo.SetVisible();
		m_gizmo.SetEnabled();
		m_gizmo.m_color = c_gold;
		m_gizmo.m_alpha = 0.75;
		
		m_editor.m_statusbar.m_toolHelpText = "Click-drag to create tiles. Enter to commit changes.";
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
				
				with (m_editor)
				{
					var kInputHeight = other.m_tileMax.z;
					
					for (var ix = other.m_tileMin.x; ix <= other.m_tileMax.x; ++ix)
					{
						for (var iy = other.m_tileMin.y; iy <= other.m_tileMax.y; ++iy)
						{
							var existingTile = MapGetPosition(ix, iy);
							// create a new block at position if it doesn't exist yet
							if (!is_struct(existingTile))
							{
								var maptile = new AMapTile();
								maptile.x = ix;
								maptile.y = iy;
								maptile.height = kInputHeight;
								
								array_push(mapTiles, maptile);
							}
							// otherwise, heighten the block if it's lower than the gizmo height
							else
							{
								if (existingTile.height < kInputHeight)
								{
									MapRemoveHeightSlow(existingTile.height); // TODO: defer this.
									existingTile.height = kInputHeight;
								}
							}
						}
					}
					
					MapAddHeight(kInputHeight);
					MapRebuildGraphics();
				}
				
			}
			
			// Check for building the map up
			if ((keyboard_check_pressed(vk_enter) && keyboard_check(vk_alt))
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
							var existingTileIndex = MapGetPositionIndex(ix, iy);
							
							if (existingTileIndex >= 0)
							{
								var existingTile = mapTiles[existingTileIndex];
								
								// lower the height of the tile if the input height is high enough
								if (kInputHeight >= 0)
								{
									if (existingTile.height > kInputHeight)
									{
										MapRemoveHeightSlow(existingTile.height); // TODO: defer this.
										existingTile.height = kInputHeight;
									}
								}
								// otherwise, we delete the tile
								else
								{
									MapRemoveHeightSlow(existingTile.height);
									array_delete(mapTiles, existingTileIndex, 1); // TODO: defer this.
								}
							}
						}
					}
					
					if (kInputHeight >= 0)
						MapAddHeight(kInputHeight);
					MapRebuildGraphics();
				}
				
			}
		}
		
	};
}

/// @function AEditorToolStateTileHeight() constructor
function AEditorToolStateTileHeight() : AEditorToolState() constructor
{
	state = kEditorToolTileHeight;
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
		if (button == mb_left && buttonState == kEditorToolButtonStateMake)
		{
			with (m_editor)
			{
				var maptile = MapGetPosition(toolTileX, toolTileY);
				if (is_struct(maptile))
				{
					MapRemoveHeightSlow(maptile.height);
					maptile.height += 1;
					MapAddHeight(maptile.height);
				
					MapRebuildGraphics();
				}
			}
		}
		if (button == mb_right && buttonState == kEditorToolButtonStateMake)
		{
			with (m_editor)
			{
				var maptile = MapGetPosition(toolTileX, toolTileY);
				if (is_struct(maptile))
				{
					MapRemoveHeightSlow(maptile.height);
					maptile.height = max(0, maptile.height - 1);
					MapAddHeight(maptile.height);
				
					MapRebuildGraphics();
				}
			}
		}
	};
	
	m_gizmo = null;
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoSelectBox3D);
		m_gizmo.SetVisible();
		m_gizmo.SetEnabled();
		m_gizmo.m_color = merge_color(c_gray, c_blue, 0.25);
		m_gizmo.m_alpha = 0.5;
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.SetInvisible();
			m_gizmo.SetDisabled();
		}
	};
	onStep = function()
	{
		m_gizmo.m_min.x = m_editor.toolTileX * 16 + 1;
		m_gizmo.m_min.y = m_editor.toolTileY * 16 + 1;
		m_gizmo.m_min.z = -2;
		m_gizmo.m_max.x = m_editor.toolTileX * 16 + 16 - 1;
		m_gizmo.m_max.y = m_editor.toolTileY * 16 + 16 - 1;
		m_gizmo.m_max.z = 16 + 2;
	};
}