#macro kMapPropmapFeature_XYZ				0x0001
#macro kMapPropmapFeature_StaticLighting	0x0002
#macro kMapPropmapFeature_VertexLighting	0x0004

function EncodeAngleToS16(angle)
{
	return round(angle_difference(angle, 0) * (32400.0 / 180.0)); // closest div to 1/180th degrees (for fractional support)
}
function DecodeAngleFromS16(encoded)
{
	return (encoded * (180.0 / 32400.0)); // closest div to 1/180th degrees (for fractional support)
}

function MapLoadProps(filedata, propmap)
{
	var buffer = filedata.blob_props;
	if (buffer == null) return;
	buffer_seek(buffer, buffer_seek_start, 0);
	
	// Propmap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	props
	
	var featureset = buffer_read(buffer, buffer_u32);
	var elementcount = buffer_read(buffer, buffer_u32);
	var extrainfoA = buffer_read(buffer, buffer_u32);
	var extrainfoB = buffer_read(buffer, buffer_u32);
	
	if (featureset & kMapPropmapFeature_XYZ)
	{
		// Assuming the APropMap already emptied, load and add props into it:
		// Each entry will be a APropEntry:
		//	f16[3]	position
		//	s16[3]	rotation
		//	f16[3]	scale
		//	u8		image_index
		//	u8[24]	asset name
	
		for (var propIndex = 0; propIndex < elementcount; ++propIndex)
		{
			var prop = new APropEntry();
		
			prop.x = buffer_read(buffer, buffer_f16);
			prop.y = buffer_read(buffer, buffer_f16);
			prop.z = buffer_read(buffer, buffer_f16);
		
			prop.xrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			prop.yrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
			prop.zrotation = DecodeAngleFromS16(buffer_read(buffer, buffer_s16));
		
			prop.xscale = buffer_read(buffer, buffer_f16);
			prop.yscale = buffer_read(buffer, buffer_f16);
			prop.zscale = buffer_read(buffer, buffer_f16);
		
			prop.index = buffer_read(buffer, buffer_u8);
			var asset_name = buffer_read_byte_array(buffer, 24);
			prop.sprite = PropFindAssetByName(asset_name);
		
		
			propmap.AddProp(prop);
		}
	}
}

function MapSaveProps(filedata, propmap)
{
	if (filedata.blob_props != null)
	{
		buffer_delete(filedata.blob_props);
	}
	
	var buffer = buffer_create(0, buffer_grow, 1);
	
	// Propmap formats:
	//	u32			feature set
	//	u32			element count
	//	u32			extra info A
	//	u32			extra info B
	//	varies[]	tiles
	
	buffer_write(buffer, buffer_u32, kMapPropmapFeature_XYZ);
	buffer_write(buffer, buffer_u32, propmap.GetPropCount());
	buffer_write(buffer, buffer_u32, 0);
	buffer_write(buffer, buffer_u32, 0);
	
	for (var propIndex = 0; propIndex < propmap.GetPropCount(); ++propIndex)
	{
		var prop = propmap.GetProp(propIndex);
		
		// Assuming the APropMap already emptied, load and add props into it:
		// Each entry will be a APropEntry:
		//	f16[3]	position
		//	s16[3]	rotation
		//	f16[3]	scale
		//	u8		image_index
		//	u8[24]	asset name
		
		buffer_write(buffer, buffer_f16, prop.x);
		buffer_write(buffer, buffer_f16, prop.y);
		buffer_write(buffer, buffer_f16, prop.z);
		
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(prop.xrotation));
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(prop.yrotation));
		buffer_write(buffer, buffer_s16, EncodeAngleToS16(prop.zrotation));
		
		buffer_write(buffer, buffer_f16, prop.xscale);
		buffer_write(buffer, buffer_f16, prop.yscale);
		buffer_write(buffer, buffer_f16, prop.zscale);
		
		buffer_write(buffer, buffer_u8, prop.index);
		var asset_name = sprite_get_name(prop.sprite);
		if (string_length(asset_name) > 24)
		{
			asset_name = string_copy(asset_name, string_length(asset_name) - 24 + 1, 24);
		}
		buffer_write_byte_array(buffer, asset_name, 24);
	}
	
	// Save the buffer we just created to the filedata.
	filedata.blob_props = buffer;
}