///@function layer_get_tilemap_fallback(layer)
function layer_get_tilemap_fallback(in_layer)
{
	// This only works for editor-placed tilemaps
	var tilemap = layer_tilemap_get_id(in_layer);
	
	// Check if the tilemap we retrieved is valid. If not, then we have to search for it in an alternate way
	if (!layer_tilemap_exists(in_layer, tilemap))
	{
		tilemap = null;
		
		// If we're using a procedurally created tilemap, we have to loop through all the elements and grab the tilemap that way.
		var all_elements = layer_get_all_elements(in_layer);
		for (var iElement = 0; iElement < array_length(all_elements); ++iElement)
		{
			var possible_tilemap = all_elements[iElement];
			if (layer_get_element_type(possible_tilemap) == layerelementtype_tilemap)
			{
				tilemap = possible_tilemap;
				break;
			}
		}
	}
	
	return tilemap;
}
