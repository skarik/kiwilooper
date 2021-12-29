/// @description Update the test (Camera & Editor)

controlUpdate(false);

m_toolbar.x = 10;
m_toolbar.y = 20;
m_toolbar.Step(uPosition - GameCamera.view_x, vPosition - GameCamera.view_y);

CameraUpdate();
GizmoUpdate();

if (toolCurrent == kEditorToolCamera)
{
	var bMouseLeft = mouse_check_button(mb_left);
	var bMouseRight = mouse_check_button(mb_right);
	if (bMouseLeft && !bMouseRight)
	{
		cameraRotZ -= (uPosition - uPositionPrevious) * 0.2;
		cameraRotY += (vPosition - vPositionPrevious) * 0.2;
	}
	else if (bMouseRight && !bMouseLeft)
	{
		cameraX += lengthdir_x((vPosition - vPositionPrevious), cameraRotZ)
				 + lengthdir_y((uPosition - uPositionPrevious), cameraRotZ);
				 
		cameraY += lengthdir_y((vPosition - vPositionPrevious), cameraRotZ)
				 - lengthdir_x((uPosition - uPositionPrevious), cameraRotZ);
	}
}

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

if (toolCurrent == kEditorToolTileHeight)
{
	if (!m_toolbar.ContainsMouse())
	{
		if (mouse_check_button_pressed(mb_left))
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
		if (mouse_check_button_pressed(mb_right))
		{
			var maptile = MapGetPosition(toolTileX, toolTileY);
			if (is_struct(maptile))
			{
				MapRemoveHeightSlow(maptile.height);
				maptile.height -= 1;
				MapAddHeight(maptile.height);
				
				MapRebuildGraphics();
			}
		}
	}
}