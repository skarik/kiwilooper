// Interface to save/load from blobs to the ATilemap structure.

#macro kMapTilemapFeature_XYHeight			0x0001
#macro kMapTilemapFeature_TextureRotation	0x0002

function MapLoadTilemap(filedata, tilemap)
{
	var buffer = filedata.blob_tilemap;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Tilemap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	tiles
	
	var featureset = buffer_read(buffer, buffer_u32);
	var elementcount = buffer_read(buffer, buffer_u32);
	var extrainfoA = buffer_read(buffer, buffer_u32);
	var extrainfoB = buffer_read(buffer, buffer_u32);
	
	if (featureset & kMapTilemapFeature_XYHeight|kMapTilemapFeature_TextureRotation)
	{
		for (var elementIndex = 0; elementIndex < elementcount; ++elementIndex)
		{
			var tile = new AMapTile();
			
			if (featureset & kMapTilemapFeature_XYHeight)
			{
				// We have the simplest kind of featureset.
				// Assuming the ATilemap already exists, we simply add tiles.
				// Each entry will be a AMapTile:
				//	u8		floorType
				//	u8		wallType
				//	s8		height
				//	s16		x
				//	s16		y
				
				tile.floorType	= buffer_read(buffer, buffer_u8);
				tile.wallType	= buffer_read(buffer, buffer_u8);
				tile.height		= buffer_read(buffer, buffer_s8);
				tile.x			= buffer_read(buffer, buffer_s16);
				tile.y			= buffer_read(buffer, buffer_s16);
			}
			
			if (featureset & kMapTilemapFeature_TextureRotation)
			{
				//	kMapTilemapFeature_TextureRotation:
				//		u16		rotation & flip flags
		
				var tile_flags	= buffer_read(buffer, buffer_u16);
				tile.floorRotate90	= (tile_flags & 0x1) != 0;
				tile.floorFlipX		= (tile_flags & 0x2) != 0;
				tile.floorFlipY		= (tile_flags & 0x4) != 0;
			}
			
			tilemap.AddTile(tile);
		}
		
		// After reading in, we fix up the heights:
		for (var tileIndex = 0; tileIndex < array_length(tilemap.tiles); ++tileIndex)
		{
			tilemap.AddHeight(tilemap.tiles[tileIndex].height);
		}
	}
	else
	{
		assert(false); // Unsupported featureset.
	}
}

function MapSaveTilemap(filedata, tilemap)
{
	if (filedata.blob_tilemap != null)
	{
		buffer_delete(filedata.blob_tilemap);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Tilemap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	tiles
	
	buffer_write(buffer, buffer_u32, kMapTilemapFeature_XYHeight | kMapTilemapFeature_TextureRotation);
	buffer_write(buffer, buffer_u32, array_length(tilemap.tiles));
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_u32, 0);
	
	for (var tileIndex = 0; tileIndex < array_length(tilemap.tiles); ++tileIndex)
	{
		// Each entry will be a AMapTile:
		//	kMapTilemapFeature_XYHeight:
		//		u8		floorType
		//		u8		wallType
		//		s8		height
		//		s16		x
		//		s16		y
		//	kMapTilemapFeature_TextureRotation:
		//		u16		rotation & flip flags
		
		var tile = tilemap.tiles[tileIndex];
		buffer_write(buffer, buffer_u8, tile.floorType);
		buffer_write(buffer, buffer_u8, tile.wallType);
		buffer_write(buffer, buffer_s8, tile.height);
		buffer_write(buffer, buffer_s16, tile.x);
		buffer_write(buffer, buffer_s16, tile.y);
		
		// Texture rotation
		buffer_write(buffer, buffer_u16, 
					(tile.floorRotate90 ? 0x1 : 0)
					| (tile.floorFlipX ? 0x2 : 0)
					| (tile.floorFlipY ? 0x14: 0)
					);
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_tilemap = buffer;
}