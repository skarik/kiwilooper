/// @function ModelCacheRead(kch_filename, mdl_filename)
function ModelCacheRead(kch_filename, mdl_filename)
{
	var cached_data = undefined;
	
	var model_edit_time	= faudioUtilGetFileLastEditTime(mdl_filename);
	var kch_edit_time	= faudioUtilGetFileLastEditTime(kch_filename);
				
	// Is our cache younger than our model? Then it's up-to-date!
	if (kch_edit_time > model_edit_time)
	{
		var filecache_buffer = buffer_load(kch_filename);
		if (buffer_exists(filecache_buffer))
		{
			debugLog(kLogVerbose, "Cached mesh found, loading.");
						
			// Read in the time (unused atm)
			var cache_creation = buffer_read(filecache_buffer, buffer_u64);
				
			// Read in the other data
			var cacheFrameCount = buffer_read(filecache_buffer, buffer_u32);
			var cacheVertCount = buffer_read(filecache_buffer, buffer_u32);
			var cacheVertBufferSize = buffer_read(filecache_buffer, buffer_u32);
			
			// Set up array
			cached_data = array_create(cacheFrameCount, undefined);
				
			// Read in the frames
			for (var frameIndex = 0; frameIndex < cacheFrameCount; ++frameIndex)
			{
				var cacheFrameByteSize = buffer_read(filecache_buffer, buffer_u32);
				var cacheFrameData = buffer_read_buffer(filecache_buffer, buffer_fixed, cacheFrameByteSize);
				// Create vertex buffer now
				cached_data[frameIndex] = vertex_create_buffer_from_buffer_ext(cacheFrameData, meshb_CreateVertexFormat(), 0, cacheVertCount);
				// Done with loaded data
				buffer_delete(cacheFrameData);
			}
				
			// Done with loaded buffer
			buffer_delete(filecache_buffer);
				
			// Return cached data!
		}
	}
	return cached_data;
}

/// @function ModelCacheWrite(kch_filename, frame_count, mesh_frames)
function ModelCacheWrite(kch_filename, frame_count, mesh_frames)
{
	var total_output_buffer = buffer_create(0, buffer_grow, 1);
				
	// Write time of the cache
	buffer_write(total_output_buffer, buffer_u64, faudioUtilGetCurrentTime());
	// Write size of meshes
	buffer_write(total_output_buffer, buffer_u32, frame_count);
	// Write the buffer size info
	buffer_write(total_output_buffer, buffer_u32, vertex_get_number(mesh_frames[0]));
	buffer_write(total_output_buffer, buffer_u32, vertex_get_buffer_size(mesh_frames[0]));
				
	// Write out all the meshes
	for (var iframe = 0; iframe < frame_count; ++iframe)
	{
		var frame_buffer = buffer_create_from_vertex_buffer(mesh_frames[iframe], buffer_fixed, 1);
		buffer_write(total_output_buffer, buffer_u32, buffer_get_size(frame_buffer));
		buffer_write_buffer(total_output_buffer, frame_buffer);
		buffer_delete(frame_buffer);
	}
				
	// Save to file
	var kch_output_filename = fioGetDatafileDirectory() + "\\" + kch_filename;
	debugLog(kLogVerbose, "Caching to \"" + kch_output_filename + "\"");
	buffer_save(total_output_buffer, kch_output_filename);
	// Clear up data
	buffer_delete(total_output_buffer);
}