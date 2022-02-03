/// @description Set up camera & routines.

event_inherited();

// Need control input for this
controlInit();

x = 0;
y = 0;
z = 0;

EditorToolsSetup();

// List of all layers currently used for the tiles and props.
intermediateLayers = [];
// Rebuilds all the graphics for the map: props & tilemap
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
		for (var layerIndex = 0; layerIndex < array_length(m_tilemap.usedHeights); ++layerIndex)
		{
			var layerHeight = m_tilemap.usedHeights[layerIndex];
			assert(is_real(layerHeight) || is_int32(layerHeight) || is_int64(layerHeight));
		
			var newTileLayer = layer_create(100 - layerHeight, "floor" + string(layerHeight));
			array_push(intermediateLayers, newTileLayer);
			
			var tilemap = layer_tilemap_create(newTileLayer, 0, 0, tileset_lab0, 256, 256);
			for (var tileIndex = 0; tileIndex < array_length(m_tilemap.tiles); ++tileIndex)
			{
				// If tile matches the height, then we add it to the rendering
				var tileInfo = m_tilemap.tiles[tileIndex];
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
			for (var tileIndex = 0; tileIndex < array_length(m_tilemap.tiles); ++tileIndex)
			{
				var tileInfo = m_tilemap.tiles[tileIndex];
				tilemap_set(tilemap, tile_set_index(0, tileInfo.wallType), tileInfo.x, tileInfo.y);
			}
		}
	}
	
	// Set up the props
	m_propmap.RebuildPropLayer(intermediateLayers);
	
	// Create the 3d-ify chain
	inew(o_tileset3DIze);
}
MapRebuilPropsOnly = function()
{
	// Delete existing renderers
	idelete(o_props3DIze);
	
	// Delete the matching intermediate layer
	for (var layerIndex = 0; layerIndex < array_length(intermediateLayers); ++layerIndex)
	{
		var layer_name = layer_get_name(intermediateLayers[layerIndex]);
		var layer_name_search_position = string_pos("props", layer_name);
		if (layer_name_search_position != 0)
		{
			layer_destroy(intermediateLayers[layerIndex]);
			array_delete(intermediateLayers, layerIndex, 1);
			break;
		}
	}
	
	// Set up the props
	m_propmap.RebuildPropLayer(intermediateLayers);
	
	// Create the missing part of the 3d-ify chain
	inew(o_props3DIze);
}

EditorUIBitsSetup();
EditorCameraSetup();
EditorGizmoSetup();

EditorTileMapSetup();
EditorPropMapSetup();