/// @description Create mesh based on the tilesets we find
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
		gml_pragma("forceinline");
		if (x < 0 || y < 0 || x >= width || y >= height)
			return m_defaultHeight;
		return array[x + y * width];
	},
	set: function(x, y, value) {
		gml_pragma("forceinline");
		array[x + y * width] = value;
	},
	
	getExtras: function(x, y) {
		gml_pragma("forceinline");
		if (x < 0 || y < 0 || x >= width || y >= height)
			return m_defaultHeight;
		return array_extras[x + y * width];
	},
	setExtras: function(x, y, value) {
		gml_pragma("forceinline");
		array_extras[x + y * width] = value;
	},
};

m_tilemap2 = null;
m_mesh = null;

SetTilemap = function(tilemap2)
{
	m_tilemap2 = tilemap2;
}
BuildMesh = function()
{
	m_mesh = meshb_Begin();
	buildHeightmap(m_tilemap2);
	buildFloors(m_tilemap2);
	buildWalls(m_tilemap2);
	meshb_End(m_mesh);
}
	
#region Build Mesh

buildHeightmap = function(tilemap2)
{
	// Grab tilemap total size
	var tilemap_width = 0;
	var tilemap_height = 0;
	for (var tileIndex = 0; tileIndex < array_length(tilemap2.tiles); ++tileIndex)
	{
		var tile = tilemap2.tiles[tileIndex];
		// Update size
		tilemap_width = max(tilemap_width, tile.x);
		tilemap_height = max(tilemap_height, tile.y);
			
		// Update bbox
		m_minPosition.x = min(m_minPosition.x, tile.x * 16);
		m_minPosition.y = min(m_minPosition.y, tile.y * 16);
		m_minPosition.z = min(m_minPosition.z, tile.height * 16);
			
		m_maxPosition.x = min(m_maxPosition.x, tile.x * 16);
		m_maxPosition.y = min(m_maxPosition.y, tile.y * 16);
		m_maxPosition.z = min(m_maxPosition.z, tile.height * 16);
	}
		
	m_heightMap.expandTo(tilemap_width, tilemap_height);
		
	// Set up heightmap
	for (var tileIndex = 0; tileIndex < array_length(tilemap2.tiles); ++tileIndex)
	{
		var tile = tilemap2.tiles[tileIndex];
		m_heightMap.set(tile.x, tile.y, tile.height);
			
		// Get tile X & Y in tileset
		var tile_x = tile.floorType % 16;
		var tile_y = floor(tile.floorType / 16);
			
		if (tile_y >= 8 && tile_y < 12 && tile_x >= 0 && tile_x < 4)
		{
			m_heightMap.set(tile.x, tile.y, tile.height - 0.25);
			m_heightMap.setExtras(tile.x, tile.y, kTileExtras_Shock);
		}
	}
}
	
buildFloors = function(tilemap2)
{
	var uvs = sprite_get_uvs(stl_lab0, 0);
		
	for (var tileIndex = 0; tileIndex < array_length(tilemap2.tiles); ++tileIndex)
	{
		var tile = tilemap2.tiles[tileIndex];
		var ix = tile.x;
		var iy = tile.y;
		var height = tile.height;
			
		// Get tile X & Y in tileset
		var tile_x = tile.floorType % 16;
		var tile_y = floor(tile.floorType / 16);
			
		// Do specific tile fuckery 
		var zoffset = 0;
		// Shock tile specifics
		if (tile_y >= 8 && tile_y < 12 && tile_x >= 0 && tile_x < 4)
		{
			zoffset = -4;
				
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
		var tile_angle = tile.floorRotate90 ? 90 : 0;
		var tile_scale = new Vector2( tile.floorFlipX ? -1 : 1, tile.floorFlipY ? -1 : 1 );
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
	
buildWalls = function(tilemap2)
{
	var uvs = sprite_get_uvs(stl_lab0, 0);
		
	for (var tileIndex = 0; tileIndex < array_length(tilemap2.tiles); ++tileIndex)
	{
		var tile = tilemap2.tiles[tileIndex];
		var ix = tile.x;
		var iy = tile.y;
		var height = tile.height;
			
		// Get actual base tile index
		var tile_top_index = tile.wallType % 32 + (64 * floor(tile.wallType / 64));
		var tile_bot_index = tile_top_index + 32;
			
		// Get tile scale
		var tile_scale = new Vector2( tile.floorFlipX ? -1 : 1, 1.0 );
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
		static offsets = [
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
			} // End check of each wall
		}
	}
}

#endregion

// Define rendering
m_renderEvent = function()
{
	if (m_mesh != null)
	{
		vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
	}
}

// Mark this tileset as the collision one
if (global.tiles_main == null)
{
	global.tiles_main = id;
}
