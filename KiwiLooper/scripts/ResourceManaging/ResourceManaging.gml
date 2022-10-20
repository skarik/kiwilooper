#macro kResourceTypeInvalid		0
#macro kResourceTypeMDL			1
#macro kResourceTypeMD2			2
#macro kResourceTypePNG			3

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
		var uvs = sprite_get_uvs(mesh_textures[0], 0);
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
			texture: sprite_get_texture(new_sprite, 0),
		};
	
		// Save into texture listing
		global.resourceMap[?filepath_indexer] = new_texture_resource;
		
		return new_texture_resource;
	}
	
	return undefined;
}
