/// @function AEditorToolStateTileEditor() constructor
function AEditorToolStateTileEditor() : AEditorToolState() constructor
{
	state = kEditorToolTileEditor;
	
	// not ready:
		// on click -> begin drag
		// on release -> end drag
	
	// ready:
		// on escape: not ready
		// on enter: ready
		
	m_hasShapeReady = false;
	m_isDraggingShape = false;
	m_skipFrame = false;
	
	m_dragPositionStart = new Vector3();
	m_dragPositionEnd = new Vector3();
	
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
				
				m_dragPositionStart.x = m_editor.toolFlatX;
				m_dragPositionStart.y = m_editor.toolFlatY;
				m_dragPositionStart.z = 0;
				
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
		
		/*
		if (button == mb_left && buttonState == kEditorToolButtonStateMake)
		{
			with (m_editor)
			{
				// create a new block at position if it doesn't exist yet
				if (!MapHasPosition(toolTileX, toolTileY))
				{
					var maptile = new AMapTile();
					maptile.x = toolTileX;
					maptile.y = toolTileY;
			
					array_push(mapTiles, maptile);
			
					MapAddHeight(maptile.height);
					MapRebuildGraphics();
				}
			}
		}
		else if (button == mb_right && buttonState == kEditorToolButtonStateMake)
		{
			with (m_editor)
			{
				var maptile_index = MapGetPositionIndex(toolTileX, toolTileY);
				if (maptile_index >= 0)
				{
					var tile_height = mapTiles[maptile_index].height;
				
					array_delete(mapTiles, maptile_index, 1);
				
					MapRemoveHeightSlow(tile_height);
					MapRebuildGraphics();
				}
			}
		}*/
	};
	
	m_gizmo = null;
	
	onBegin = function()
	{
		//m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoFlatGridCursorBox);
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoFlatEditBox);
		m_gizmo.m_visible = true;
		m_gizmo.m_enabled = true;
		m_gizmo.m_color = c_gold;
		m_gizmo.m_alpha = 0.75;
		
		m_editor.m_statusbar.m_toolHelpText = "Click-drag to create tiles. Enter to commit changes.";
		
		/*m_gizmo.m_min.x = m_editor.toolTileX * 16 - 16 - 2;
		m_gizmo.m_min.y = m_editor.toolTileY * 16 - 16 - 2;
		m_gizmo.m_min.z = -1;
		m_gizmo.m_max.x = m_editor.toolTileX * 16 + 16 + 16 + 2;
		m_gizmo.m_max.y = m_editor.toolTileY * 16 + 16 + 16 + 2;
		m_gizmo.m_max.z = -1;*/
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.m_visible = false;
			m_gizmo.m_enabled = false;
		}
	};
	onStep = function()
	{
		m_skipFrame = false;
		/*m_gizmo.m_min.x = m_editor.toolTileX * 16 - 2;
		m_gizmo.m_min.y = m_editor.toolTileY * 16 - 2;
		m_gizmo.m_min.z = -1;
		m_gizmo.m_max.x = m_editor.toolTileX * 16 + 16 + 2;
		m_gizmo.m_max.y = m_editor.toolTileY * 16 + 16 + 2;
		m_gizmo.m_max.z = -1;*/
		
		// Initial waiting for input:
		if (!m_hasShapeReady)
		{
			// Hide the gizmo.
			m_gizmo.m_enabled = false;
			m_gizmo.m_visible = false;
		}
		// Dragging state:
		else if (m_isDraggingShape)
		{
			// Update the gizmo.
			m_gizmo.m_enabled = true;
			m_gizmo.m_visible = true;
			
			m_dragPositionEnd.x = m_editor.toolFlatX;
			m_dragPositionEnd.y = m_editor.toolFlatY;
			m_dragPositionEnd.z = 0;
			
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
			if (keyboard_check_pressed(vk_enter)
				|| m_gizmo.m_editWantsCommit)
			{
				m_isDraggingShape = false;
				m_hasShapeReady = false;
				m_skipFrame = true; // Skip the next click event. TODO: make this a common call.
				// TODO.
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
		m_gizmo.m_visible = true;
		m_gizmo.m_enabled = true;
		m_gizmo.m_color = merge_color(c_gray, c_blue, 0.25);
		m_gizmo.m_alpha = 0.5;
	};
	onEnd = function(trueEnd)
	{
		if (trueEnd)
		{
			m_gizmo.m_visible = false;
			m_gizmo.m_enabled = false;
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