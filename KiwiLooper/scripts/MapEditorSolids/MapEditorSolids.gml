function AMapSolid() constructor
{
	faces = [];
	vertices = [];
	
	static GetBBox = function()
	{
		var min_pos = vertices[0].position.copy();
		var max_pos = vertices[0].position.copy();
		
		for (var i = 1; i < array_length(vertices); ++i)
		{
			min_pos.x = min(min_pos.x, vertices[i].position.x);
			min_pos.y = min(min_pos.y, vertices[i].position.y);
			min_pos.z = min(min_pos.z, vertices[i].position.z);
			
			max_pos.x = max(max_pos.x, vertices[i].position.x);
			max_pos.y = max(max_pos.y, vertices[i].position.y);
			max_pos.z = max(max_pos.z, vertices[i].position.z);
		}
		
		return BBox3FromMinMax(min_pos, max_pos);
	}
	
	static GetFaceBBox = function(faceIndex)
	{
		var min_pos = vertices[faces[faceIndex].indicies[0]].position.copy();
		var max_pos = vertices[faces[faceIndex].indicies[0]].position.copy();
		
		for (var i = 1; i < array_length(faces[faceIndex].indicies); ++i)
		{
			min_pos.x = min(min_pos.x, vertices[faces[faceIndex].indicies[i]].position.x);
			min_pos.y = min(min_pos.y, vertices[faces[faceIndex].indicies[i]].position.y);
			min_pos.z = min(min_pos.z, vertices[faces[faceIndex].indicies[i]].position.z);
			
			max_pos.x = max(max_pos.x, vertices[faces[faceIndex].indicies[i]].position.x);
			max_pos.y = max(max_pos.y, vertices[faces[faceIndex].indicies[i]].position.y);
			max_pos.z = max(max_pos.z, vertices[faces[faceIndex].indicies[i]].position.z);
		}
		
		return BBox3FromMinMax(min_pos, max_pos);
	}
	
	static TriangulateFace = function(faceIndex, triangleFan)
	{
		var triangles = [];
		var face = faces[faceIndex];
		var index_count = array_length(face.indicies);
		
		assert(index_count > 2);
		
		// Triangle
		if (index_count == 3)
		{
			triangles = [[face.indicies[0], face.indicies[1], face.indicies[2]]];
		}
		// Quad
		else if (index_count == 4)
		{
			triangles = [
				[face.indicies[0], face.indicies[1], face.indicies[2]],
				[face.indicies[2], face.indicies[3], face.indicies[0]]
			];
		}
		// Convex Polygon
		else
		{
			if (triangleFan)
			{
				// Add a triangle, fanning out from the first vertex
				for (var i = 2; i < index_count; ++i)
				{
					array_push(triangles, [face.indicies[0], face.indicies[i], face.indicies[i-1]]);
				}
			}
			else
			{
				// Add triangles for all the edges
				for (var i = 2; i <= floor(index_count / 2) * 2; i += 2)
				{
					array_push(triangles, [face.indicies[i-2], face.indicies[i-1], face.indicies[i % index_count]]);
				}
				// Fill in the center holes
				for (var i = 4; i < index_count; i += 2)
				{
					array_push(triangles, [face.indicies[0], face.indicies[i-2], face.indicies[i]]);
				}
			}
		}
		
		return triangles;
	}
	
	static ReadFromBuffer = function(buffer)
	{
		// faces[]
		var face_count = buffer_read(buffer, buffer_u8);
		faces = array_create(face_count);
		for (var faceIndex = 0; faceIndex < face_count; ++faceIndex)
		{
			faces[faceIndex] = (new AMapSolidFace()).ReadFromBuffer(buffer);
		}
		// vertices[]
		var vertex_count = buffer_read(buffer, buffer_u8);
		vertices = array_create(vertex_count);
		for (var vertexIndex = 0; vertexIndex < vertex_count; ++vertexIndex)
		{
			vertices[vertexIndex] = (new AMapSolidVertex()).SerializeBuffer(buffer, kIoRead, SerializeReadDefault);
		}
		return self;
	}
	static WriteToBuffer = function(buffer)
	{
		// faces[]
		buffer_write(buffer, buffer_u8, array_length(faces));
		for (var faceIndex = 0; faceIndex < array_length(faces); ++faceIndex)
		{
			faces[faceIndex].WriteToBuffer(buffer);
		}
		// vertices[]
		buffer_write(buffer, buffer_u8, array_length(vertices));
		for (var vertexIndex = 0; vertexIndex < array_length(vertices); ++vertexIndex)
		{
			vertices[vertexIndex].SerializeBuffer(buffer, kIoWrite, SerializeWriteDefault);
		}
		return self;
	}
}

function AMapSolidFace() constructor
{
	indicies = [];
	uvinfo = new AMapSolidFaceUVInfo();
	texture = new AMapSolidFaceTexture();
	
	static ReadFromBuffer = function(buffer)
	{
		// Index array
		var index_count = buffer_read(buffer, buffer_u8);
		indicies = array_create(index_count);
		for (var indexIndex = 0; indexIndex < index_count; ++indexIndex)
		{
			indicies[indexIndex] = real(buffer_read(buffer, buffer_u8));
		}
		
		// uvinfo
		uvinfo.SerializeBuffer(buffer, kIoRead, SerializeReadDefault);
		
		// texture
		texture.SerializeBuffer(buffer, kIoRead, SerializeReadDefault);
		
		return self;
	}
	static WriteToBuffer = function(buffer)
	{
		// Index array
		buffer_write(buffer, buffer_u8, array_length(indicies));
		for (var indexIndex = 0; indexIndex < array_length(indicies); ++indexIndex)
		{
			buffer_write(buffer, buffer_u8, indicies[indexIndex]);
		}
		
		// uvinfo
		uvinfo.SerializeBuffer(buffer, kIoWrite, SerializeWriteDefault);
		
		// texture
		texture.SerializeBuffer(buffer, kIoWrite, SerializeWriteDefault);
		
		return self;
	}
}

#macro kTextureTypeSprite			0
#macro kTextureTypeSpriteTileset	1
#macro kTextureTypeTexture			2

function AMapSolidFaceTexture() constructor
{
	// Type of texture
	type = kTextureTypeSpriteTileset;
	// Source of the data.
	//	When a Sprite, is a Game Maker sprite handle.
	//	When a Texture, is a filepath to a resource. It is up to the renderer to handle the resource loading.
	source = stl_lab0;
	index = 1;
	
	// UID used internally for identification
	uid = null;
	// Resource information used internally for storage.
	// Usually either: Resource or {atlas, in_atlas_index, Resource}
	resource_handle = undefined;
	
	static Equals = function(otherTexture)
	{
		return
			type == otherTexture.type
			&& source == otherTexture.source
			&& index == otherTexture.index;
	}
	
	static BuildUID = function()
	{
		gml_pragma("forceinline");
		if (type == kTextureTypeSpriteTileset || type == kTextureTypeSprite)
		{
			uid = string(type) + sprite_get_name(source) + string(index);
		}
		else if (type == kTextureTypeTexture)
		{
			uid = string(type) + source;
		}
		return uid;
	}
	static GetUID = function()
	{
		gml_pragma("forceinline");
		return uid;
	}
	
	static GetTextureSize = function()
	{
		gml_pragma("forceinline");
		if (type == kTextureTypeSpriteTileset)
		{
			return [16, 16];
		}
		else if (type == kTextureTypeSprite)
		{
			return [sprite_get_width(source), sprite_get_height(source)];
		}
		else if (type == kTextureTypeTexture)
		{
			debugLog(kLogError, "Cannot query AMapSolidFaceTexture size from textures.");
			return [16, 16];
		}
		else
		{
			debugLog(kLogError, "Invalid AMapSolidFaceTexture type \"" + string(type) + "\"");
			return [16, 16];
		}
	}
	static GetTextureUVs = function()
	{
		if (type == kTextureTypeSprite)
		{
			return sprite_get_uvs(source, index);
		}
		else if (type == kTextureTypeSpriteTileset)
		{
			var uv_source = sprite_get_uvs(source, 0);
			
			var div_x = int64(index) % 16;
			var div_y = floor(index / 16);
			
			return [
				lerp(uv_source[0], uv_source[2], div_x / 16),
				lerp(uv_source[1], uv_source[3], div_y / 16),
				lerp(uv_source[0], uv_source[2], (div_x + 1) / 16),
				lerp(uv_source[1], uv_source[3], (div_y + 1) / 16)];
		}
		else if (type == kTextureTypeTexture)
		{
			debugLog(kLogError, "Cannot query AMapSolidFaceTexture UVs from textures.");
			return [0, 0, 16, 16];
		}
	}
	static GetTextureSubUVs = function(in_atlas_uvs)
	{
		if (type == kTextureTypeSprite
			|| type == kTextureTypeTexture)
		{
			return in_atlas_uvs;
		}
		else if (type == kTextureTypeSpriteTileset)
		{
			var uv_source = in_atlas_uvs;
			
			var div_x = int64(index) % 16;
			var div_y = floor(index / 16);
			
			return [
				lerp(uv_source[0], uv_source[2], div_x / 16),
				lerp(uv_source[1], uv_source[3], div_y / 16),
				lerp(uv_source[0], uv_source[2], (div_x + 1) / 16),
				lerp(uv_source[1], uv_source[3], (div_y + 1) / 16)];
		}
	}
	
	static SerializeBuffer = function(buffer, ioMode, io_ser)
	{
		io_ser(self, "type", buffer, buffer_u8);
		if (type == kTextureTypeSprite || type == kTextureTypeSpriteTileset)
		{
			io_ser(self, "source", buffer, buffer_u64);
			io_ser(self, "index", buffer, buffer_u16);
		}
		else if (type == kTextureTypeTexture)
		{
			io_ser(self, "source", buffer, buffer_string);
			io_ser(self, "index", buffer, buffer_u16);
		}
		else
		{
			debugLog(kLogError, "Invalid AMapSolidFaceTexture type \"" + string(type) + "\"");
		}
		return self;
	}
}

#macro kSolidMappingWorld 0		// Specific case of Normal, where normal is locked to nearest axes
#macro kSolidMappingFace 1		// Specific case of Normal, where normal is locked to the face's normal
#macro kSolidMappingNormal 2

function AMapSolidFaceUVInfo() constructor
{
	mapping = kSolidMappingWorld;
	normal = new Vector3(0, 0, 1.0);
	scale = new Vector2(1.0, 1.0);
	offset = new Vector2(0, 0);
	rotation = 0.0;
	
	static TransformPoint = function(io_coord, solidTexture, textureSize)
	{
		var tex_size;
		if (solidTexture.type == kTextureTypeTexture)
		{
			tex_size = textureSize;
		}
		else
		{
			tex_size = solidTexture.GetTextureSize();
		}
		
		io_coord.addSelf(offset);
		
		io_coord.x /= tex_size[0];
		io_coord.y /= tex_size[1];
		
		io_coord.multiplyComponentSelf(scale).rotateSelf(rotation);
		
		// Bias to the UVs? Or do we want to do this in the shader?
		// Let's just...do this in the shader, methinks
		//uvPoint.biasUVSelf(face_tex_uvs);
	}
	
	static SerializeBuffer = function(buffer, ioMode, io_ser)
	{
		io_ser(self, "mapping", buffer, buffer_u8);
		io_ser(normal, "x", buffer, buffer_f64);
		io_ser(normal, "y", buffer, buffer_f64);
		io_ser(normal, "z", buffer, buffer_f64);
		io_ser(scale, "x", buffer, buffer_f64);
		io_ser(scale, "y", buffer, buffer_f64);
		io_ser(offset, "x", buffer, buffer_f64);
		io_ser(offset, "y", buffer, buffer_f64);
		io_ser(self, "rotation", buffer, buffer_f64);
		return self;
	}
}

function AMapSolidVertex() constructor
{
	position = new Vector3(0, 0, 0);
	
	static SerializeBuffer = function(buffer, ioMode, io_ser)
	{
		io_ser(position, "x", buffer, buffer_f64);
		io_ser(position, "y", buffer, buffer_f64);
		io_ser(position, "z", buffer, buffer_f64);
		return self;
	}
}