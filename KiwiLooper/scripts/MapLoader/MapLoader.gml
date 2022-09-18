#macro kMapHeaderWord_Tilemap	0x0001
#macro kMapHeaderWord_Props		0x0002
#macro kMapHeaderWord_Entities	0x0004
#macro kMapHeaderWord_Splats	0x0008
#macro kMapHeaderWord_Editor	0x0010

function MapFreeFiledata(filedata)
{
	if (filedata.blob_tilemap != null)
	{
		buffer_delete(filedata.blob_tilemap);
		filedata.blob_tilemap = null;
	}
	
	if (filedata.blob_props != null)
	{
		buffer_delete(filedata.blob_props);
		filedata.blob_props = null;
	}
	
	if (filedata.blob_entities != null)
	{
		buffer_delete(filedata.blob_entities);
		filedata.blob_entities = null;
	}
	
	if (filedata.blob_splats != null)
	{
		buffer_delete(filedata.blob_splats);
		filedata.blob_splats = null;
	}
	
	if (filedata.blob_editor != null)
	{
		buffer_delete(filedata.blob_editor);
		filedata.blob_editor = null;
	}
}

function AMapFiledata() constructor
{
	blob_tilemap = null;
	blob_props = null;
	blob_entities = null;
	blob_splats = null;
	blob_editor = null;
}

function MapLoadFiledata(filepath)
{
	var filedata = new AMapFiledata();
	
	// Each blob is the following format:
	//	u32		type
	//	u32		crc32 checksum
	//	u64		size
	//	u8[]	blob
	
	var rawbuffer = null;
	
	// We want to try several variations of the filepath, for easier dev:
	var filepath_variations = [
		filepath,
		"maps/" + filepath,
		filepath + ".kmf",
		"maps/" + filepath + ".kmf",
		];
		
	// attempt loads until we find success with one of the filepath variations
	for (var i = 0; i < array_length(filepath_variations); ++i)
	{
		rawbuffer = fioReadToBuffer(filepath_variations[i]);
		if (rawbuffer != null) 
		{
			break;
		}
	}
	assert(rawbuffer != null);
	
	// If it's null, we return failure - so that the loader can check this and enter a useful error state
	if (rawbuffer == null)
	{
		return null;
	}
	
	// Now we read in until we're at the end of the file
	var l_eof = false;
	while (!l_eof)
	{
		// Read in the mini-header
		var blobtype = buffer_read(rawbuffer, buffer_u32);
		var checksum = buffer_read(rawbuffer, buffer_u32);
		var size = buffer_read(rawbuffer, buffer_u64);
		
		// Read in blob via allocate & copy
		var blob = buffer_create(size, buffer_fixed, 1);
		buffer_copy(rawbuffer, buffer_tell(rawbuffer), size, blob, 0);
		
		// Perform CRC check
		assert(buffer_crc32(blob, 0, size) == checksum);
		
		switch (blobtype)
		{
		case kMapHeaderWord_Tilemap:
			filedata.blob_tilemap = blob;
			break;
			
		case kMapHeaderWord_Props:
			filedata.blob_props = blob;
			break;
			
		case kMapHeaderWord_Entities:
			filedata.blob_entities = blob;
			break;
			
		case kMapHeaderWord_Splats:
			filedata.blob_splats = blob;
			break;
			
		case kMapHeaderWord_Editor:
			filedata.blob_editor = blob;
			break;
			
		default:
			assert(false); // Should never get here
		}
		
		// Done, we seek forward to the next blob
		buffer_seek(rawbuffer, buffer_seek_relative, size);
		
		// Check for end of buffer
		l_eof = buffer_tell(rawbuffer) >= buffer_get_size(rawbuffer);
	}
	
	buffer_delete(rawbuffer);
	
	return filedata;
}

function MapSaveFiledata(filepath, filedata)
{
	// Each blob is the following format:
	//	u32		type
	//	u32		crc32 checksum
	//	u64		size
	//	u8[]	blob
	
	static GetSize = function(blob)
	{
		if (blob != null)
		{
			return buffer_get_size(blob)
				+ 4		// type
				+ 4		// crc32 checksum
				+ 8;	// size
		}
		return 0;
	}
	
	static WriteBlob = function(outbuffer, blob, type)
	{
		var size = buffer_get_size(blob);
		var checksum = buffer_crc32(blob, 0, size);
		
		buffer_write(outbuffer, buffer_u32, type);
		buffer_write(outbuffer, buffer_u32, checksum);
		buffer_write(outbuffer, buffer_u64, size);
		
		var cursor = buffer_tell(outbuffer);
		buffer_copy(blob, 0, size, outbuffer, cursor);
		buffer_seek(outbuffer, buffer_seek_start, cursor + size);
	}
	
	var total_size = GetSize(filedata.blob_tilemap)
		+ GetSize(filedata.blob_props)
		+ GetSize(filedata.blob_entities)
		+ GetSize(filedata.blob_splats)
		+ GetSize(filedata.blob_editor);
	
	// Create a slow temp buffer for writing
	var outbuffer = buffer_create(total_size, buffer_fixed, 1);
	
	// Save the blobs to the temp buffer
	if (filedata.blob_tilemap != null)
	{
		WriteBlob(outbuffer, filedata.blob_tilemap, kMapHeaderWord_Tilemap);
	}
	if (filedata.blob_props != null)
	{
		WriteBlob(outbuffer, filedata.blob_props, kMapHeaderWord_Props);
	}
	if (filedata.blob_entities != null)
	{
		WriteBlob(outbuffer, filedata.blob_entities, kMapHeaderWord_Entities);
	}
	if (filedata.blob_splats != null)
	{
		WriteBlob(outbuffer, filedata.blob_splats, kMapHeaderWord_Splats);
	}
	if (filedata.blob_editor != null)
	{
		WriteBlob(outbuffer, filedata.blob_editor, kMapHeaderWord_Editor);
	}
	
	// Save the information
	//var absolutePath = fioLocalFileFindAbsoluteFilepath(filepath);
	//buffer_save(outbuffer, absolutePath);
	buffer_save(outbuffer, filepath);
	
	// Done with the data
	buffer_delete(outbuffer);
}