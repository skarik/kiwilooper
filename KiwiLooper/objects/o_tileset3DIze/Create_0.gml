/// @description Create mesh based on the tilesets we find
#macro kTileExtras_None 0
#macro kTileExtras_Shock 1

var all_layers = layer_get_all();

m_minPosition = new Vector3(10000, 10000, 10000);
m_maxPosition = new Vector3(-10000, -10000, -10000);
m_heightMap = {
	array: array_create(0),
	array_extras: array_create(0),
	width: 0,
	height: 0,
	
	m_defaultHeight: ((room == rm_Ship5) ? -4 : -1),
	
	expandTo: function(w, h) {
		width = max(width, w);	
		height = max(width, h);
		
		if (array_length(array) < width * height)
		{
			array = array_create(width * height, m_defaultHeight);
			array_extras = array_create(width * height, kTileExtras_None);
		}
	},
	get: function(x, y) {
		if (x < 0 || y < 0 || x >= width || y >= height)
			return m_defaultHeight;
		return array[x + y * width];
	},
	set: function(x, y, value) {
		array[x + y * width] = value;
	},
	
	getExtras: function(x, y) {
		if (x < 0 || y < 0 || x >= width || y >= height)
			return m_defaultHeight;
		return array_extras[x + y * width];
	},
	setExtras: function(x, y, value) {
		array_extras[x + y * width] = value;
	},
};

m_mesh = meshb_Begin();
{
	// Build the layer to the mesh
	var buildLayer = function(tilemap, height)
	{
		var uvs = sprite_get_uvs(stl_lab0, 0);
		m_heightMap.expandTo(tilemap_get_width(tilemap), tilemap_get_height(tilemap));
		
		for (var ix = 0; ix < tilemap_get_width(tilemap); ++ix)
		{
			for (var iy = 0; iy < tilemap_get_height(tilemap); ++iy)
			{
				var tile = tilemap_get(tilemap, ix, iy);
				var tile_index = tile_get_index(tile);
				if (tile_index == 0)
					continue;
					
				// Update height here
				m_heightMap.set(ix, iy, max(height, m_heightMap.get(ix, iy)));
				
				// Update the bounding box of the map
				m_minPosition.x = min(ix * 16, m_minPosition.x);
				m_minPosition.y = min(iy * 16, m_minPosition.y);
				m_minPosition.z = min(height * 16, m_minPosition.z);
			
				m_maxPosition.x = max(ix * 16, m_maxPosition.x);
				m_maxPosition.y = max(iy * 16, m_maxPosition.y);
				m_maxPosition.z = max(height * 16, m_maxPosition.z);
				
				// Get tile X & Y in tileset
				var tile_x = tile_index % 16;
				var tile_y = floor(tile_index / 16);
				
				// Do specific tile fuckery 
				var zoffset = 0;
				// Shock tile specifics
				if (tile_y >= 8 && tile_y < 12 && tile_x >= 0 && tile_x < 4)
				{
					zoffset = -4;
					m_heightMap.set(ix, iy, m_heightMap.get(ix, iy) - 0.25);
					m_heightMap.setExtras(ix, iy, kTileExtras_Shock);
					
					var overlay = inew(o_effectPowerOverlay);
						overlay.x = ix * 16 + 8;
						overlay.y = iy * 16 + 8;
						overlay.z = height * 16 + zoffset;
				}
			
				// Calculate new UVs for this
				var new_uvs = [
					lerp(uvs[0], uvs[2], tile_x / 16),
					lerp(uvs[1], uvs[3], tile_y / 16),
					lerp(uvs[0], uvs[2], (tile_x + 1) / 16),
					lerp(uvs[1], uvs[3], (tile_y + 1) / 16)
					];
					
				// Get new angle
				var tile_angle = tile_get_rotate(tile) ? 90 : 0;
				var tile_scale = new Vector2( tile_get_mirror(tile) ? -1 : 1, tile_get_flip(tile) ? -1 : 1 );
				tile_scale.multiplySelf(0.97);
			
				// Add a quad for the floor
				meshb_AddQuad(m_mesh, [
					new MBVertex(new Vector3(ix * 16,		iy * 16,		height * 16 + zoffset),
						c_white, 1.0, (new Vector2(-1, -1)).rotate(tile_angle).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs), new Vector3(0, 0, 1)),
					new MBVertex(new Vector3(ix * 16 + 16,	iy * 16,		height * 16 + zoffset),
						c_white, 1.0, (new Vector2(+1, -1)).rotate(tile_angle).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs), new Vector3(0, 0, 1)),
					new MBVertex(new Vector3(ix * 16,		iy * 16 + 16,	height * 16 + zoffset),
						c_white, 1.0, (new Vector2(-1, +1)).rotate(tile_angle).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs), new Vector3(0, 0, 1)),
					new MBVertex(new Vector3(ix * 16 + 16,	iy * 16 + 16,	height * 16 + zoffset),
						c_white, 1.0, (new Vector2(+1, +1)).rotate(tile_angle).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs), new Vector3(0, 0, 1))
					]);
				
			}
		}
	};
	
	// Build the wall layer to the mesh
	var buildWalls = function(tilemap)
	{
		var uvs = sprite_get_uvs(stl_lab0, 0);
		
		for (var ix = 0; ix < tilemap_get_width(tilemap); ++ix)
		{
			for (var iy = 0; iy < tilemap_get_height(tilemap); ++iy)
			{
				var tile = tilemap_get(tilemap, ix, iy);
				var tile_index = tile_get_index(tile);
				if (tile_index == 0)
					continue;
					
				// Get actual base tile index
				var tile_top_index = tile_index % 32 + (64 * floor(tile_index / 64));
				var tile_bot_index = tile_top_index + 32;
				
				// Get tile scale
				var tile_scale = new Vector2( tile_get_mirror(tile) ? -1 : 1, 1.0 );
				tile_scale.multiplySelf(0.97);
				
				// Calculate new UVs for this
				var tile_x, tile_y, new_uvs, new_uvsTop;
				
				tile_x = tile_bot_index % 16;
				tile_y = floor(tile_bot_index / 16);
				new_uvs = [
					lerp(uvs[0], uvs[2], tile_x / 16),
					lerp(uvs[1], uvs[3], tile_y / 16),
					lerp(uvs[0], uvs[2], (tile_x + 1) / 16),
					lerp(uvs[1], uvs[3], (tile_y + 1) / 16)
					];
					
				tile_x = tile_top_index % 16;
				tile_y = floor(tile_top_index / 16);
				new_uvsTop = [
					lerp(uvs[0], uvs[2], tile_x / 16),
					lerp(uvs[1], uvs[3], tile_y / 16),
					lerp(uvs[0], uvs[2], (tile_x + 1) / 16),
					lerp(uvs[1], uvs[3], (tile_y + 1) / 16)
					];
					
				// Check top, add wall
				var offsets = [
					{x: 0, y: -1},
					{x: 0, y: +1},
					{x: -1, y: 0},
					{x: +1, y: 0}
					];
				
				var height0 = m_heightMap.get(ix, iy);
				for (var iw = 0; iw < 4; ++iw)
				{
					var heightn = m_heightMap.get(ix + offsets[iw].x, iy + offsets[iw].y);
				
					// Add a quad for the floor
					if (height0 > heightn)
					{
						var x_push = max(offsets[iw].x, 0) * 16;
						var y_push = max(offsets[iw].y, 0) * 16;
						var x_off = (offsets[iw].y == 0) ? 0 : 16;
						var y_off = (offsets[iw].x == 0) ? 0 : 16;
						var wall_color = (heightn <= -1) ? c_dkgray : c_white;
						
						meshb_AddQuad(m_mesh, [
							new MBVertex(
								new Vector3(ix * 16 + x_push,			iy * 16 + y_push,			heightn * 16 + min(1.0, height0 - heightn) * 16),
								wall_color, 1.0,
								(new Vector2(-1, -1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs),
								new Vector3(offsets[iw].x, offsets[iw].y, 0)),
							new MBVertex(
								new Vector3(ix * 16 + x_push + x_off,	iy * 16 + y_push + y_off,	heightn * 16 + min(1.0, height0 - heightn) * 16),
								wall_color, 1.0,
								(new Vector2(+1, -1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs),
								new Vector3(offsets[iw].x, offsets[iw].y, 0)),
							new MBVertex(
								new Vector3(ix * 16 + x_push,			iy * 16 + y_push,			heightn * 16 + 0),
								wall_color, 1.0,
								(new Vector2(-1, +1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs),
								new Vector3(offsets[iw].x, offsets[iw].y, 0)),
							new MBVertex(
								new Vector3(ix * 16 + x_push + x_off,	iy * 16 + y_push + y_off,	heightn * 16 + 0),
								wall_color, 1.0,
								(new Vector2(+1, +1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvs),
								new Vector3(offsets[iw].x, offsets[iw].y, 0))
							]);
							
						for (var iz = heightn + 1; iz < height0; ++iz)
						{
							var fractional = min(1, height0 - iz);
							
							meshb_AddQuad(m_mesh, [
								new MBVertex(
									new Vector3(ix * 16 + x_push,			iy * 16 + y_push,			iz * 16 + 16 * fractional),
									wall_color, 1.0,
									(new Vector2(-1, -1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvsTop),
									new Vector3(offsets[iw].x, offsets[iw].y, 0)),
								new MBVertex(
									new Vector3(ix * 16 + x_push + x_off,	iy * 16 + y_push + y_off,	iz * 16 + 16 * fractional),
									wall_color, 1.0,
									(new Vector2(+1, -1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvsTop),
									new Vector3(offsets[iw].x, offsets[iw].y, 0)),
								new MBVertex(
									new Vector3(ix * 16 + x_push,			iy * 16 + y_push,			iz * 16 + 0),
									wall_color, 1.0,
									(new Vector2(-1, +1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvsTop),
									new Vector3(offsets[iw].x, offsets[iw].y, 0)),
								new MBVertex(
									new Vector3(ix * 16 + x_push + x_off,	iy * 16 + y_push + y_off,	iz * 16 + 0),
									wall_color, 1.0,
									(new Vector2(+1, +1)).multiplyComponentSelf(tile_scale).unbiasSelf().biasUVSelf(new_uvsTop),
									new Vector3(offsets[iw].x, offsets[iw].y, 0))
								]);
						}
					}
				} // End check of each wall
			}
		}
	};

	// Add mesh based on the layers
	for (var i = 0; i < array_length(all_layers); ++i)
	{
		var current_layer = all_layers[i];
	
		var tilemap = layer_get_tilemap_fallback(current_layer);
		if (tilemap == null)
		{
			continue;
		}
		
		var layer_name = layer_get_name(current_layer);
		var layer_name_search_position = string_pos("floor", layer_name);
		if (layer_name_search_position != 0)
		{
			var layer_name_post_numeral = string_char_at(layer_name, min(layer_name_search_position + 5, string_length(layer_name)));
			if (!is_numeral(layer_name_post_numeral))
			{
				show_error("bad layer named, \"" + layer_name_post_numeral + "\", shit!", true);
			}
		
			var current_height = real(layer_name_post_numeral);
			buildLayer(tilemap, current_height);
		}
	}
	
	for (var i = 0; i < array_length(all_layers); ++i)
	{
		var current_layer = all_layers[i];
	
		var tilemap = layer_get_tilemap_fallback(current_layer);
		if (tilemap == null)
		{
			continue;
		}
		
		var layer_name = layer_get_name(current_layer);
		var layer_name_search_position = string_pos("walls", layer_name);
		if (layer_name_search_position != 0)
		{
			buildWalls(tilemap);
		}
	}
}
meshb_End(m_mesh);

// Define rendering
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
}

// Mark this tileset as the collision one
if (global.tiles_main == null)
{
	global.tiles_main = id;
}

// Now that we have elevation, we can build props!
if (global.tiles_main == id)
{
	if (!iexists(o_props3DIze))
	{
		inew(o_props3DIze);
	}
}
