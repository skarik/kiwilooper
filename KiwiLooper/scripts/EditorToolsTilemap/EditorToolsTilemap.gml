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
}