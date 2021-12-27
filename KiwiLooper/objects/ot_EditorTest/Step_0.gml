/// @description Update the test (Camera & Editor)

controlUpdate(false);

m_toolbar.x = 10;
m_toolbar.y = 20;
m_toolbar.Step(uPosition - GameCamera.view_x, vPosition - GameCamera.view_y);

CameraUpdate();
GizmoUpdate();

if (toolCurrent == kEditorToolTileEditor)
{
	if (!m_toolbar.ContainsMouse() && mouse_check_button_pressed(mb_left))
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