#macro kResourceTypeInvalid		0
#macro kResourceTypeMDL			1
#macro kResourceTypeMD2			2
#macro kResourceTypePNG			3
#macro kResourceTypeInternalSprite	4
#macro kResourceTypeGLTF		5

function ResourceMapInit()
{
	global.resourceMap = ds_map_create();
}
gml_pragma("global", "ResourceMapInit()");

function ResourceMapFree()
{
	// todo: free contents
	ds_map_destroy(global.resourceMap);
}

function ResourceGetType(filepath)
{
	// check the ID at the start of a fle.
	var start_buff = buffer_create(4, buffer_grow, 1);
	buffer_load_partial(start_buff, filepath, 0,4, 0);
	var identifier = buffer_read(start_buff, buffer_s32);
	
	switch (identifier)
	{
	case 1330660425:	return kResourceTypeMDL;
	case 844121161:		return kResourceTypeMD2;
	
	//{{{137 80 78 71 13 10 26 10 }}}
	case 0x89504E47:	return kResourceTypePNG; // TODO: verify this
	}
	
	var file_extension = string_lower(filename_ext(filepath));
	if (file_extension == ".gltf")
	{
		return kResourceTypeGLTF;
	}
	
	return kResourceTypeInvalid;
}

function ResourceGetTypeIsTexture(resource)
{
	if (resource.type == kResourceTypePNG
		|| resource.type == kResourceTypeInternalSprite)
	{
		return true;
	}
	return false;
}

// Define macros for common resource information
#macro INTERNAL_ResourceHousekeeping references: 0, last_used: Time.time

#macro kResources_UseCachedModels true
#macro kResources_TimeModelLoader true

function ResourceLoadModel(filepath)
{
	var filepath_indexer = string_lower(filepath);
	
	// Check if already loaded the model
	var existing_resource = global.resourceMap[?filepath_indexer];
	if (!is_undefined(existing_resource))
	{
		return existing_resource;
	}
	
	var resourceType = ResourceGetType(filepath);
	if (resourceType == kResourceTypeMDL || resourceType == kResourceTypeMD2 || resourceType == kResourceTypeGLTF)
	{
		var l_load_time_start = 0;
		if (kResources_TimeModelLoader)
		{
			l_load_time_start = get_timer();
		}
		
		// Check for a KCH file to see if we can skip the slow Frames[] loading
		var bHasCachedMesh = false;
		var cached_data = undefined;
		if (kResources_UseCachedModels)
		{
			var kch_filename = string_copy(filepath, 1, string_rpos(".", filepath)) + "kch";
			debugLog(kLogVerbose, "Looking for \"" + kch_filename + "\"");
			
			cached_data = ModelCacheRead(kch_filename, filepath);
			// Did we have something loaded?
			bHasCachedMesh = !is_undefined(cached_data);
		}
		
		// Create correct parser
		var parser;
		if (resourceType == kResourceTypeMDL)
		{
			parser = new AMDLFileParser();
		}
		else if (resourceType == kResourceTypeMD2)
		{
			parser = new AMD2FileParser();
		}
		else if (resourceType == kResourceTypeGLTF)
		{
			parser = new AGLTFFileParser();
		}
		
		// Load model
		if (parser.OpenFile(filepath))
		{
			// TODO: check if bHasCachedMesh and if cached mesh matches the file
			
			// decompress the model
			var bReadFramesOk = bHasCachedMesh || parser.ReadFrames();
			if (!bReadFramesOk || !parser.ReadTextures())
			{
				show_error("beansed it", true);
			}
		}
		else
		{
			return undefined;
		}
		parser.CloseFile();
		
		// Convert data
		// pull the textures! TODO: use the texture loader below
		/*if (array_length(parser.GetTextures()) > 0)
		{
			uvs = sprite_get_uvs(parser.GetTextures()[0], 0);
			m_texture = sprite_get_texture(parser.GetTextures()[0], 0);
		}*/
		
		// todo: check textures as well
		var textureCount = array_length(parser.GetTextures());
		var mesh_textures = array_create(textureCount);
		for (var itexture = 0; itexture < textureCount; ++itexture)
		{
			mesh_textures[itexture] = parser.GetTextures()[itexture];
		}
		
		var frameCount = parser.GetFrameCount();
		var mesh_frames = array_create(frameCount);
		
		// create render meshes from the data
		if (!bHasCachedMesh)
		{
			assert(frameCount == array_length(parser.GetFrames()));
			
			var uvs = sprite_get_uvs(mesh_textures[0].sprite, 0);
			for (var iframe = 0; iframe < frameCount; ++iframe)
			{
				var frame = parser.GetFrames()[iframe];
				var frame_mesh = meshb_Begin();
				for (var i = 0; i < frame.count; ++i)
				{
					if (kMD2_IsFlatAttributeArrays)
					{
						meshb_PushVertex2(frame_mesh,
							frame.vertices[i*3+0], frame.vertices[i*3+1], frame.vertices[i*3+2],
							c_white, 1.0,
							lerp(uvs[0], uvs[2], frame.texcoords[i*2+0]), lerp(uvs[0], uvs[2], frame.texcoords[i*2+1]),
							frame.normals[i*3+0], frame.normals[i*3+1], frame.normals[i*3+2]
							);
					}
					else
					{
						meshb_PushVertex2(frame_mesh,
							frame.vertices[i][0], frame.vertices[i][1], frame.vertices[i][2],
							c_white, 1.0,
							lerp(uvs[0], uvs[2], frame.texcoords[i][0]), lerp(uvs[0], uvs[2], frame.texcoords[i][1]),
							frame.normals[i][0], frame.normals[i][1], frame.normals[i][2]
							);
					}
				}
				meshb_End(frame_mesh);
	
				mesh_frames[iframe] = frame_mesh;
			}
			
			// Save the cached stuff
			if (kResources_UseCachedModels)
			{
				var kch_filename = string_copy(filepath, 1, string_rpos(".", filepath)) + "kch";
				ModelCacheWrite(kch_filename, frameCount, mesh_frames);
			}
		}
		else
		{
			// Copy cached data to mesh_frames
			for (var iframe = 0; iframe < frameCount; ++iframe)
			{
				mesh_frames[iframe] = cached_data[iframe];
			}
		}
		
		// and we're done w/ parser
		delete parser;
		
		// check for a KAI file as well
		var mesh_animation = undefined;
		{
			var kai_filename = string_copy(filepath, 1, string_rpos(".", filepath)) + "kai";
			debugLog(kLogVerbose, "Looking for \"" + kai_filename + "\"");
			
			// Loads up all the kai data and puts it into a useable form
			mesh_animation = KAILoadInfo(kai_filename);
		}
		
		// done loading
		if (kResources_TimeModelLoader)
		{
			var elapsed_time = get_timer() - l_load_time_start;
			debugLog(kLogOutput, "Loading took " + string(elapsed_time / 1000.0) + "ms");
		}
		
		// save data in new resource
		var new_model_resource = {
			frames: mesh_frames,
			textures: mesh_textures,
			animation: mesh_animation,
			INTERNAL_ResourceHousekeeping,
			type: resourceType,
		};
		
		// Save into model listing
		global.resourceMap[?filepath_indexer] = new_model_resource;
		
		return new_model_resource;
	}
	else
	{
	}
	
	return undefined;
}

/// @function ResourceLoadTexture(filepath, target_width, target_height)
/// desc Loads the given filepath.
function ResourceLoadTexture(filepath, target_width, target_height)
{
	var filepath_indexer = string_lower(filepath);
	
	// Check if already loaded the texture
	var existing_resource = global.resourceMap[?filepath_indexer];
	if (!is_undefined(existing_resource))
	{
		return existing_resource;
	}
	
	// Load in the texture as a sprite
	var new_sprite = sprite_add(filepath, 1, false, false, 0, 0);
	if (sprite_exists(new_sprite))
	{
		var new_texture_resource = {
			sprite:	new_sprite,
			texture_ptr: sprite_get_texture(new_sprite, 0),
			INTERNAL_ResourceHousekeeping,
			type: kResourceTypePNG,
		};
	
		// Save into texture listing
		global.resourceMap[?filepath_indexer] = new_texture_resource;
		
		return new_texture_resource;
	}
	
	return undefined;
}

/// @function ResourceAddTexture(filepath_indentifier, target_sprite)
function ResourceAddTexture(filepath_indentifier, target_sprite)
{
	var filepath_indexer = string_lower(filepath_indentifier);
	
	// Check if there's a name conflict
	var existing_resource = global.resourceMap[?filepath_indexer];
	if (!is_undefined(existing_resource))
	{
		show_error("Name collision in the resource system.", false);
	}
	
	// Save the texture as a sprite
	{
		var new_texture_resource = {
			sprite:	target_sprite,
			texture_ptr: sprite_get_texture(target_sprite, 0),
			INTERNAL_ResourceHousekeeping,
			type: kResourceTypeInternalSprite,
		};
	
		// Save into texture listing
		global.resourceMap[?filepath_indexer] = new_texture_resource;
		
		return new_texture_resource;
	}
}

/// @function ResourceFindSpriteTexture(target_sprite)
function ResourceFindSpriteTexture(target_sprite)
{
	var current_key = ds_map_find_first(global.resourceMap);
	for (var i = 0; i < ds_map_size(global.resourceMap); ++i)
	{
		var resource = global.resourceMap[?current_key];
		if (resource.type == kResourceTypeInternalSprite
			&& resource.sprite == target_sprite)
		{
			return resource;
		}
		current_key = ds_map_find_next(global.resourceMap, current_key);
	}
	return undefined;
}
/// @function ResourceFindTexture(filepath)
function ResourceFindTexture(filepath)
{
	var filepath_indexer = string_lower(filepath);
	
	// Check if already loaded the texture
	var existing_resource = global.resourceMap[?filepath_indexer];
	if (!is_undefined(existing_resource))
	{
		return existing_resource;
	}
	
	return undefined;
}

/// @function ResourceAddReference(resource)
/// @desc Incremenets refcount of resource. Remember to pair properly with ResourceRemoveReference!
function ResourceAddReference(resource)
{
	resource.references += 1;
	resource.last_used = Time.time;
}
/// @function ResourceRemoveReference(resource)
/// @desc Decrements refcount of resource.
function ResourceRemoveReference(resource)
{
	resource.references -= 1;
	// Update the "no longer used" time to NOW.
	if (resource.references <= 0)
	{
		resource.last_used = Time.time;
	}
}