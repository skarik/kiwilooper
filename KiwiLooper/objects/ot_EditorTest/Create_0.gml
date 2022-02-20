/// @description Set up camera & routines.

event_inherited();

// Need control input for this
controlInit();

x = 0;
y = 0;
z = 0;

EditorToolsSetup();

m_currentMapName = "";

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
	
	// Set up the tiles
	m_tilemap.BuildLayers(intermediateLayers);
	
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
EditorSelectionSetup();

EditorTileMapSetup();
EditorPropMapSetup();
m_entityInstList = new AEntityList();