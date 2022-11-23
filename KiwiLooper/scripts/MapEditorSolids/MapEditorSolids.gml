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
	}
}

#macro kTextureTypeSprite 0
#macro kTextureTypeSpriteTileset 1

function AMapSolidFaceTexture() constructor
{
	type = kTextureTypeSpriteTileset;
	source = stl_lab0;
	index = 0;
	
	static Equals = function(otherTexture)
	{
		return
			type == otherTexture.type
			&& source == otherTexture.source
			&& index == otherTexture.index;
	}
	
	static SerializeBuffer = function(buffer, ioMode, io_ser)
	{
		io_ser(self, "type", buffer, buffer_u8);
		if (type == kTextureTypeSprite || type == kTextureTypeSpriteTileset)
		{
			io_ser(self, "source", buffer, buffer_u64);
			io_ser(self, "index", buffer, buffer_u16);
		}
		else
		{
			debugLog(kLogError, "Invalid AMapSolidFaceTexture type \"" + string(type) + "\"");
		}
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
	}
}