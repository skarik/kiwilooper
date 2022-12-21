#macro kResourceTypeInvalid		0
#macro kResourceTypeMDL			1
#macro kResourceTypeMD2			2
#macro kResourceTypePNG			3
#macro kResourceTypeInternalSprite	4

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
	if (resourceType == kResourceTypeMDL || kResourceTypeMD2)
	{
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
		
		// Load model
		if (parser.OpenFile(filepath))
		{
			// decompress the model
			if (!parser.ReadFrames() || !parser.ReadTextures())
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
		
		var frameCount = array_length(parser.GetFrames());
		var mesh_frames = array_create(frameCount);
		
		// create render meshes from the data
		var uvs = sprite_get_uvs(mesh_textures[0].sprite, 0);
		for (var iframe = 0; iframe < frameCount; ++iframe)
		{
			var frame = parser.GetFrames()[iframe];
			var frame_mesh = meshb_Begin();
			for (var i = 0; i < array_length(frame.vertices); ++i)
			{
				meshb_PushVertex(frame_mesh, 
					new MBVertex(
						Vec3(frame.vertices[i][0], frame.vertices[i][1], frame.vertices[i][2]),
						c_white, 1.0,
						(new Vector2(frame.texcoords[i][0], frame.texcoords[i][1])).biasUVSelf(uvs),
						Vec3(frame.normals[i][0], frame.normals[i][1], frame.normals[i][2])
						)
					);
			}
			meshb_End(frame_mesh);
	
			mesh_frames[iframe] = frame_mesh;
		}
		
		// and we're done w/ parser
		delete parser;
		
		// save data in new resource
		var new_model_resource = {
			frames: mesh_frames,
			textures: mesh_textures,
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

///@function ResourceAddReference(resource)
///@desc Incremenets refcount of resource. Remember to pair properly with ResourceRemoveReference!
function ResourceAddReference(resource)
{
	resource.references += 1;
	resource.last_used = Time.time;
}
///@function ResourceRemoveReference(resource)
///@desc Decrements refcount of resource.
function ResourceRemoveReference(resource)
{
	resource.references -= 1;
	// Update the "no longer used" time to NOW.
	if (resource.references <= 0)
	{
		resource.last_used = Time.time;
	}
}