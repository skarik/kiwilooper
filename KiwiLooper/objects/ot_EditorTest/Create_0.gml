/// @description Set up camera & routines.

event_inherited();

// Need control input for this
controlInit();

x = 0;
y = 0;
z = 0;

EditorToolsSetup();

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
	m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 3, "Translate", kEditorToolTranslate));
	//m_toolbar.AddElement(AToolbarElementAsToolButtonInfo(suie_toolsetBasic, 1, "Zoom", kEditorToolZoom));
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

EditorCameraSetup();
EditorGizmoSetup();