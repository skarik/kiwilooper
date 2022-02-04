#macro kMapHeaderWord_Tilemap	0x0001
#macro kMapHeaderWord_Props		0x0002
#macro kMapHeaderWord_Entities	0x0004

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
}

function AMapFiledata() constructor
{
	blob_tilemap = null;
	blob_props = null;
	blob_entities = null;
}

function MapLoadFiledata(filepath)
{
	var filedata = new AMapFiledata();
	
	// Each blob is the following format:
	//	u32		type
	//	u32		crc32 checksum
	//	u64		size
	//	u8[]	blob
	
	var rawbuffer = fioReadToBuffer(filepath);
	
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
	
	static WriteBlob = function(outbuffer, blob, type)
	{
		var size = buffer_get_size(blob);
		var checksum = buffer_crc32(blob, 0, size);
		
		buffer_write(outbuffer, buffer_u32, type);
		buffer_write(outbuffer, buffer_u32, checksum);
		buffer_write(outbuffer, buffer_u64, size);
		
		var cursor = buffer_tell(outbuffer);
		buffer_resize(outbuffer, buffer_get_size(outbuffer) + size);
		buffer_copy(blob, 0, size, outbuffer, cursor);
		buffer_seek(outbuffer, cursor + size, buffer_seek_start);
	}
	
	// Create a slow temp buffer for writing
	var outbuffer = buffer_create(0, buffer_grow, 1);
	
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
	
	// Save the information
	//var absolutePath = fioLocalFileFindAbsoluteFilepath(filepath);
	//buffer_save(outbuffer, absolutePath);
	buffer_save(outbuffer, filepath);
	
	// Done with the data
	buffer_delete(outbuffer);
}