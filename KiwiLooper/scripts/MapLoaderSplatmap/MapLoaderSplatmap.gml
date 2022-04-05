#macro kMapSplatmapFeature_XYZRotSize		0x0001
function MapLoadSplats(filedata, splatmap)
{
	var buffer = filedata.blob_splats;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Splatmap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	props
	
	var featureset = buffer_read(buffer, buffer_u32);
	var elementcount = buffer_read(buffer, buffer_u32);
	var extrainfoA = buffer_read(buffer, buffer_u32);
	var extrainfoB = buffer_read(buffer, buffer_u32);
	
	if (featureset & kMapSplatmapFeature_XYZRotSize)
	{
		// Assuming the ASplatMap already emptied, load and add props into it:
		// Each entry will be a ASplatEntry:
		//	f16[3]	position
		//	s16[3]	rotation
		//	f16[3]	scale
		//	u32		color
		//	u8		blendmode
		//	u8		image_index
		//	u8[24]	asset name
	
		for (var splatIndex = 0; splatIndex < elementcount; ++splatIndex)
		{
			var splat = new APropEntry();
		
			splat.x = buffer_read(buffer, buffer_f16);
			splat.y = buffer_read(buffer, buffer_f16);
			splat.z = buffer_read(buffer, buffer_f16);
		
			splat.xrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			splat.yrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			splat.zrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
		
			splat.xscale = buffer_read(buffer, buffer_f16);
			splat.yscale = buffer_read(buffer, buffer_f16);
			splat.zscale = buffer_read(buffer, buffer_f16);
			
			splat.color = buffer_read(buffer, buffer_u32);
			splat.blend = buffer_read(buffer, buffer_u8);
		
			splat.index = buffer_read(buffer, buffer_u8);
			var asset_name = buffer_read_byte_array(buffer, 24);
			splat.sprite = SplatFindAssetByName(asset_name);
		
		
			splatmap.AddSplat(splat);
		}
	}
}

function MapSaveSplats(filedata, splatmap)
{
	if (filedata.blob_splats != null)
	{
		buffer_delete(filedata.blob_splats);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Propmap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	tiles
	
	buffer_write(buffer, buffer_u32, kMapSplatmapFeature_XYZRotSize);
	buffer_write(buffer, buffer_u32, splatmap.GetSplatCount());
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_u32, 0);
	
	for (var splatIndex = 0; splatIndex < splatmap.GetSplatCount(); ++splatIndex)
	{
		var splat = splatmap.GetSplat(splatIndex);
		
		// Assuming the ASplatMap already emptied, load and add props into it:
		// Each entry will be a ASplatEntry:
		//	f16[3]	position
		//	s16[3]	rotation
		//	f16[3]	scale
		//	u32		color
		//	u8		blendmode
		//	u8		image_index
		//	u8[24]	asset name
		
		buffer_write(buffer, buffer_f16, splat.x);
		buffer_write(buffer, buffer_f16, splat.y);
		buffer_write(buffer, buffer_f16, splat.z);
		
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(splat.xrotation));
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(splat.yrotation));
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(splat.zrotation));
		
		buffer_write(buffer, buffer_f16, splat.xscale);
		buffer_write(buffer, buffer_f16, splat.yscale);
		buffer_write(buffer, buffer_f16, splat.zscale);
		
		buffer_write(buffer, buffer_u32, splat.color);
		buffer_write(buffer, buffer_u8, splat.blend);
		
		buffer_write(buffer, buffer_u8, splat.index);
		var asset_name = sprite_get_name(splat.sprite);
		if (string_length(asset_name) > 24)
		{
			asset_name = string_copy(asset_name, string_length(asset_name) - 24 + 1, 24);
		}
		buffer_write_byte_array(buffer, asset_name, 24);
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_splats = buffer;
}