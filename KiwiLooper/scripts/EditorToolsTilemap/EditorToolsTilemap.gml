/// @function AEditorToolStateTileEditor() constructor
function AEditorToolStateTileEditor() : AEditorToolState() constructor
{
	state = kEditorToolTileEditor;
	
	onClickWorld = function(button, buttonState, screenPosition, worldPosition)
	{
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
		}
	};
	
	m_gizmo = null;
	onBegin = function()
	{
		m_gizmo = m_editor.EditorGizmoGet(AEditorGizmoFlatGridCursorBox);
		m_gizmo.m_visible = true;
		m_gizmo.m_enabled = true;
		m_gizmo.m_color = c_gold;
		m_gizmo.m_alpha = 0.75;
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
		m_gizmo.m_min.x = m_editor.toolTileX * 16 - 2;
		m_gizmo.m_min.y = m_editor.toolTileY * 16 - 2;
		m_gizmo.m_min.z = -1;
		m_gizmo.m_max.x = m_editor.toolTileX * 16 + 16 + 2;
		m_gizmo.m_max.y = m_editor.toolTileY * 16 + 16 + 2;
		m_gizmo.m_max.z = -1;
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