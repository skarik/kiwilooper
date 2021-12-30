/// @description Set up camera & routines.

event_inherited();

// Need control input for this
controlInit();

x = 0;
y = 0;
z = 0;

EditorToolsSetup();

CameraSetup = function()
{
	cameraX = 0;
	cameraY = 0;
	cameraZ = 0;
	
	cameraRotZSpeed = 0.0;
	cameraRotYSpeed = 0.0;
	
	cameraRotZ = 45;
	cameraRotY = 60;
	cameraZoom = 1.0;
	
	zstart = z;
}
CameraUpdate = function()
{
	o_Camera3D.zrotation = cameraRotZ;
	o_Camera3D.yrotation = cameraRotY;

	var kCameraDistance = 1200 * cameraZoom;
	o_Camera3D.x = cameraX + lengthdir_x(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.y = cameraY + lengthdir_y(-kCameraDistance, o_Camera3D.zrotation) * lengthdir_x(1, o_Camera3D.yrotation);
	o_Camera3D.z = cameraZ + lengthdir_y(-kCameraDistance, o_Camera3D.yrotation);

	o_Camera3D.orthographic = false;
	o_Camera3D.fov_vertical = 10;
}

GizmoSetup = function()
{
	m_gizmoObject = inew(ob_3DObject);
	
	m_gizmoObject.m_renderEvent = function()
	{
		// Draw 3D tools.
		depth = 0;
		
		draw_set_color(c_white);
		draw_rectangle(16, 16, 32, 32, true);
		draw_rectangle(-16, 16, -32, 32, true);
		draw_rectangle(16, -16, 32, -32, true);
		draw_rectangle(-16, -16, -32, -32, true);
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(f_Oxygen7);
		draw_text(32+4, 16, "+x");
		draw_text(16, 32+4, "+y");
		
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_text(-32-4, -16, "-x");
		draw_text(-16, -32-4, "-y");
		
		draw_circle(toolFlatX, toolFlatY, 4, true);
		draw_rectangle(toolTileX * 16, toolTileY * 16, toolTileX * 16 + 16, toolTileY * 16 + 16, true);
	}
}
GizmoUpdate = function()
{
	/*var pixelX = uPosition - GameCamera.view_x;
	var pixelY = vPosition - GameCamera.view_y;
	
	var viewRayPos = [o_Camera3D.x, o_Camera3D.y, o_Camera3D.z];
	var viewRayDir = o_Camera3D.viewToRay(pixelX, pixelY);
	
	var distT = abs(viewRayPos[2] / viewRayDir[2]);
	
	toolFlatX = viewRayPos[0] + viewRayDir[0] * distT;
	toolFlatY = viewRayPos[1] + viewRayDir[1] * distT;
	
	toolTileX = max(0, floor(toolFlatX / 16));
	toolTileY = max(0, floor(toolFlatY / 16));*/
}

// An unordered array of all map tiles.
mapTiles = [];
// List of all used heights.
mapUsedHeights = [];

MapGetPosition = function(x, y)
{
	for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
	{
		var tileInfo = mapTiles[tileIndex];
		if (tileInfo.x == x && tileInfo.y == y)
		{
			return tileInfo;
		}
	}
	return null;
}
MapGetPositionIndex = function(x, y)
{
	for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
	{
		var tileInfo = mapTiles[tileIndex];
		if (tileInfo.x == x && tileInfo.y == y)
		{
			return tileIndex;
		}
	}
	return -1;
}

MapHasPosition = function(x, y)
{
	return is_struct(MapGetPosition(x, y));
}

MapAddHeight = function(height)
{
	if (!array_contains(mapUsedHeights, height))
	{
		array_push(mapUsedHeights, height);
	}
}
MapRemoveHeightSlow = function(height)
{
	for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
	{
		var tileInfo = mapTiles[tileIndex];
		if (tileInfo.height == height)
		{
			return;
		}
	}
	for (var heightIndex = 0; heightIndex < array_length(mapUsedHeights); ++heightIndex)
	{
		if (mapUsedHeights[heightIndex] == height)
		{
			array_delete(mapUsedHeights, heightIndex, 1);
		}
	}
}

// List of all layers currently used for the tiles and props.
intermediateLayers = [];

MapRebuildGraphics = function()
{
	// Delete existing renderers
	idelete(o_tileset3DIze);
	idelete(o_props3DIze);
	
	// Delete all current intermediate layers
	for (var layerIndex = 0; layerIndex < array_length(intermediateLayers); ++layerIndex)
	{
		layer_destroy(intermediateLayers[layerIndex]);
	}
	intermediateLayers = [];
	
	// Set up the layers
	{
		// Start with the floors
		for (var layerIndex = 0; layerIndex < array_length(mapUsedHeights); ++layerIndex)
		{
			var layerHeight = mapUsedHeights[layerIndex];
		
			var newTileLayer = layer_create(100 - layerHeight, "floor" + string(layerHeight));
			array_push(intermediateLayers, newTileLayer);
			
			var tilemap = layer_tilemap_create(newTileLayer, 0, 0, tileset_lab0, 256, 256);
			for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
			{
				// If tile matches the height, then we add it to the rendering
				var tileInfo = mapTiles[tileIndex];
				if (tileInfo.height == layerHeight)
				{
					tilemap_set(tilemap, tile_set_index(0, tileInfo.floorType), tileInfo.x, tileInfo.y);
				}
			}
		}
		
		// Finish up with the walls
		{
			var newTileLayer = layer_create(50, "walls");
			array_push(intermediateLayers, newTileLayer);
			
			// TODO: only add walls to tiles with a lower height.
			var tilemap = layer_tilemap_create(newTileLayer, 0, 0, tileset_lab0, 256, 256);
			for (var tileIndex = 0; tileIndex < array_length(mapTiles); ++tileIndex)
			{
				var tileInfo = mapTiles[tileIndex];
				tilemap_set(tilemap, tile_set_index(0, tileInfo.wallType), tileInfo.x, tileInfo.y);
			}
		}
	}
	
	// Create the 3d-ify chain
	inew(o_tileset3DIze);
}

// Create toolbar
{
	m_toolbar = new AToolbar();
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 0, "Select", kEditorToolSelect));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 1, "Zoom", kEditorToolZoom));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 2, "Camera", kEditorToolCamera));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 1, "Add/Subtract Tiles", kEditorToolTileEditor));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTiles, 2, "Edit Elevation", kEditorToolTileHeight));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 0, "Add Prop", kEditorToolMakeProp));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetObject, 1, "Add Entity", kEditorToolMakeEntity));
	m_toolbar.AddElement(new AToolbarElement());
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 0, "Texture", kEditorToolTexture));
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetTexture, 1, "Splats", kEditorToolSplats));
}

CameraSetup();
GizmoSetup();