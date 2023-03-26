#macro kGLTF_Type_Byte		5120
#macro kGLTF_Type_UByte		5121
#macro kGLTF_Type_Short		5122
#macro kGLTF_Type_UShort	5123
#macro kGLTF_Type_UInt		5125
#macro kGLTF_Type_Float		5126

#macro kGLTF_Mode_Points		0
#macro kGLTF_Mode_LineList		1
#macro kGLTF_Mode_LineLoop		2
#macro kGLTF_Mode_LineStrip		3
#macro kGLTF_Mode_TriangleList	4
#macro kGLTF_Mode_TriangleStrip	5
#macro kGLTF_Mode_TriangleFan	6

function AFileGLTFReader() constructor
{
	static GetComponentCount = function(type)
	{
		if (type == "SCALAR")
			return 1;
		else if (type == "VEC2")
			return 2;
		else if (type == "VEC3")
			return 3;
		else if (type == "VEC4")
			return 4;
		else if (type == "MAT2")
			return 4;
		else if (type == "MAT3")
			return 9;
		else if (type == "MAT4")
			return 16;
		return 0;
	}
	
	static GetByteSize = function(componentType)
	{
		switch (componentType)
		{
			case kGLTF_Type_Byte:	return 1;
			case kGLTF_Type_UByte:	return 1;
			case kGLTF_Type_Short:	return 2;
			case kGLTF_Type_UShort:	return 2;
			case kGLTF_Type_UInt:	return 4;
			case kGLTF_Type_Float:	return 4;
		}
		return 0;
	}
	
	static GetComponentBufferType = function(componentType)
	{
		switch (componentType)
		{
			case kGLTF_Type_Byte:	return buffer_s8;
			case kGLTF_Type_UByte:	return buffer_u8;
			case kGLTF_Type_Short:	return buffer_s16;
			case kGLTF_Type_UShort:	return buffer_u16;
			case kGLTF_Type_UInt:	return buffer_u32;
			case kGLTF_Type_Float:	return buffer_f32;
		}
		return undefined;
	}
	
	//m_blob = null; // buffer of the entire file
	m_stringblob = null;
	m_object = undefined;
	
	m_buffers = [];
	m_accessorData = [];
	
	m_primitives = [];
	m_primitiveTransforms = [];
	
	m_spriteTextures = [];
	
	static OpenFile = function(path) 
	{
		var blob = buffer_load(path);
		if (blob != -1)
		{
			m_stringblob = buffer_to_string(blob);
			buffer_delete(blob);
			// Parse the JSON!
			m_object = json_parse(m_stringblob);
		}
		
		return !is_undefined(m_object);
	}
	static CloseFile = function()
	{
		// TODO?
	}
	
	static LoadBuffers = function()
	{
		m_buffers = array_create(array_length(m_object.buffers));
		for (var bufferIndex = 0; bufferIndex < array_length(m_buffers); ++bufferIndex)
		{
			var l_targetSize	= m_object.buffers[bufferIndex].byteLength;
			var l_rawString		= m_object.buffers[bufferIndex].uri;
			
			// Let's decode the resource
			var l_dataComma = string_pos(",", l_rawString) + 1;
			var l_data64 = string_copy(l_rawString, l_dataComma, string_length(l_rawString) - l_dataComma + 1);
			
			m_buffers[bufferIndex] = buffer_create(l_targetSize, buffer_fixed, 1);
			buffer_base64_decode_ext(m_buffers[bufferIndex], l_data64, 0);
			
			// Verify size
			var l_outputSize = buffer_get_size(m_buffers[bufferIndex]);
			assert(l_outputSize == l_targetSize);
		}
		
		return true;
	}
	
	static CollectSceneMain = function()
	{
		return CollectScene(real(m_object.scene));
	}
	
	static CollectScene = function(sceneIndex)
	{
		var scene = m_object.scenes[sceneIndex];
		for (var nodeIndex = 0; nodeIndex < array_length(scene.nodes); ++nodeIndex)
		{
			CollectNode(scene.nodes[nodeIndex], [0, 0, 0], [0, 0, 0, 1], [16, 16, 16]);
		}
		return true;
	}
	
	static CollectNode = function(nodeIndex, translation, rotation, scale)
	{
		debugLog(kLogVerbose, "Collecting GLTF node " + string(nodeIndex));
		
		var node = m_object.nodes[nodeIndex];
		
		// Aggregate TRS changes
		var l_translate	= CE_ArrayClone(translation);
		var l_rotation	= CE_ArrayClone(rotation);
		var l_scale		= CE_ArrayClone(scale);
			
		if (variable_struct_exists(node, "translation"))
		{
			l_translate[0] += node.translation[0];
			l_translate[1] += node.translation[1];
			l_translate[2] += node.translation[2];
		}
		if (variable_struct_exists(node, "rotation"))
		{
			l_rotation = aquat_multiply(node.rotation, l_rotation);
		}
		if (variable_struct_exists(node, "scale"))
		{
			l_scale[0] *= node.scale[0];
			l_scale[1] *= node.scale[1];
			l_scale[2] *= node.scale[2];
		}
		if (variable_struct_exists(node, "matrix"))
		{
			debugLog(kLogWarning, "\"matrix\" is ignored in the GLTF loader!");
		}
		
		// Load the mesh up
		if (variable_struct_exists(node, "mesh"))
		{	
			var mesh_name = node.name;
			var mesh_index = node.mesh;
			
			CollectMesh(mesh_index, l_translate, l_rotation, l_scale); 
		}
		
		// Load children up
		if (variable_struct_exists(node, "children"))
		{
			for (var subnodeIndex = 0; subnodeIndex < array_length(node.children); ++subnodeIndex)
			{
				CollectNode(node.children[subnodeIndex], l_translate, l_rotation, l_scale); 
			}
		}
	}
	
	static CollectMesh = function(meshIndex, translation, rotation, scale)
	{
		var mesh = m_object.meshes[meshIndex];
		// We want to add all the geometry for the given primitive over time.
		
		// But for now, just decode the bufferViews
		for (var primitiveIndex = 0; primitiveIndex < array_length(mesh.primitives); ++primitiveIndex)
		{
			var primitive = mesh.primitives[primitiveIndex];
			
			if (primitive.mode == kGLTF_Mode_TriangleList)
			{
				// Get indicies to count triangles so we know how much to allocate
				//var triangle_count = m_object.accessors[primitive.indicies].count / 3;
				// Decode from m_object.accessors[primitive.indicies]
				
				// Collect it in the primitive list
				array_push(m_primitives, primitive);
				array_push(m_primitiveTransforms, [CE_ArrayClone(translation), CE_ArrayClone(rotation), CE_ArrayClone(scale)]);
			}
			else
			{
				debugLog(kLogWarning, "Input primitive mode not currently supported.");
			}
		}
	}
	
	static DecodeAccessors = function()
	{
		m_accessorData = array_create(array_length(m_object.accessors));
		for (var accessorIndex = 0; accessorIndex < array_length(m_object.accessors); ++accessorIndex)
		{
			m_accessorData[accessorIndex] = DecodeAccessor(accessorIndex);
		}
		
		return true;
	}
	
	static DecodeAccessor = function(accessorIndex)
	{
		var accessor = m_object.accessors[accessorIndex];
		var bufferView = m_object.bufferViews[accessor.bufferView];
		
		// Need buffers to decode the data.
		if (bufferView.buffer > array_length(m_buffers) || is_undefined(m_buffers[bufferView.buffer]))
		{
			LoadBuffers();
		}
		
		var buffer = m_buffers[bufferView.buffer];
		if (is_undefined(buffer) || !buffer_exists(buffer))
		{
			return undefined;
		}
		
		// Set up based on the view
		//buffer_seek(buffer, buffer_seek_start, bufferView.byteOffset);
		buffer_seek(buffer, buffer_seek_start, 0);
		
		var dataComponentCount = GetComponentCount(accessor.type);
		var dataComponentTypeByteSize = GetByteSize(accessor.componentType);
		var dataComponentType = GetComponentBufferType(accessor.componentType);
		var dataStride = variable_struct_exists(bufferView, "byteStride") ? bufferView.byteStride : (dataComponentTypeByteSize * dataComponentCount);
		
		// Loop through all the data in the buffer and throw it in
		var data = array_create(accessor.count * dataComponentCount);
		for (var componentIndex = 0; componentIndex < accessor.count; ++componentIndex)
		{
			for (var subIndex = 0; subIndex < dataComponentCount; ++subIndex)
			{
				data[componentIndex * dataComponentCount + subIndex] =
					buffer_peek(
						buffer,
						bufferView.byteOffset + componentIndex * dataStride + dataComponentTypeByteSize * subIndex,
						dataComponentType);
			}
			// Go to the next element in the buffer
			//buffer_seek(buffer, buffer_seek_relative, dataStride);
		}
		
		return data;
	}
	
	static ExportTextures = function()
	{
		// Loop through all the images and export some temporary files
		m_spriteTextures = array_create(array_length(m_object.images));
		for (var imageIndex = 0; imageIndex < array_length(m_object.images); ++imageIndex)
		{
			m_spriteTextures[imageIndex] = ExportAndLoadTexture(imageIndex);
		}
		
		return true;
	}
	
	static ExportAndLoadTexture = function(imageIndex)
	{
		#macro kGLTF_Temp_Texture "_temp_gltf.png"
		
		var image = m_object.images[imageIndex];
		
		// Export from the URI.
		{		
			var l_rawString		= image.uri;
			
			// Let's decode the resource
			var l_dataComma = string_pos(",", l_rawString) + 1;
			var l_data64 = string_copy(l_rawString, l_dataComma, string_length(l_rawString) - l_dataComma + 1);
			
			//var l_decodedData = base64_decode(l_data64);
			//var l_dataBuffer = buffer_create_from_string(l_decodedData);
			var l_dataBuffer = buffer_base64_decode(l_data64);
			
			buffer_save(l_dataBuffer, kGLTF_Temp_Texture);
			buffer_delete(l_dataBuffer);
		}
		
		debugLog(kLogVerbose, "saving temp texture");
		
		// Load the PNG
		var new_sprite = sprite_add(kGLTF_Temp_Texture, 0, false, false, 0, 0);
		
		// Clear out the texture
		file_delete(kGLTF_Temp_Texture);
		
		// Yay we have the texture!
		return new_sprite;
	}
}

function AGLTFFileParser() constructor
{
	m_loader = new AFileGLTFReader();
	m_frames = [];
	m_textures = [];
	m_frameCount = 0;
	
	m_modelname = "";

	/// @function GetFrames()
	static GetFrames = function()
	{
		gml_pragma("forceinline");
		return m_frames;
	}
	/// @function GetTextures()
	static GetTextures = function()
	{
		gml_pragma("forceinline");
		return m_textures;
	}
	/// @function GetFrameCount()
	static GetFrameCount = function()
	{
		return m_frameCount;
	}

	/// @function OpenFile(filepath)
	/// @desc Attempts to open & read the given file as a GLTF model
	static OpenFile = function(filepath)
	{
		m_modelname = filename_name(filepath);
		
		debugLog(kLogWarning, "Note: GLTF loadstate is not tracked, be careful when loading");
		if (!m_loader.OpenFile(filepath))
		{
			debugLog(kLogError, "Could not find file \"" + filepath + "\"");
			return false;
		}
		m_frameCount = 1;
		return true;
	}
	/// @function CloseFile(filepath)
	/// @desc Cleans up any straggling buffer information
	static CloseFile = function()
	{
		m_loader.CloseFile();
	}

	/// @function ReadFrames()
	/// @desc Takes the MD2 data and decompresses it into a tri-list that can be rendered.
	/// @returns {Boolean} success at populating data
	static ReadFrames = function()
	{
		if (m_loader.LoadBuffers() && m_loader.CollectSceneMain() && m_loader.DecodeAccessors())
		{
			var frameCount = 1;
			for (var frameIndex = 0; frameIndex < frameCount; ++frameIndex)
			{
				var triangleCount = 0;
				
				// Let's go through all the primitives
				for (var primitiveIndex = 0; primitiveIndex < array_length(m_loader.m_primitives); ++primitiveIndex)
				{
					// Count the triangles
					triangleCount += m_loader.m_object.accessors[m_loader.m_primitives[primitiveIndex].indices].count / 3;
				}
				
				// Allocate the geometry buffers
				var frame = new AMeshFrame(triangleCount * 3);
				
				frame.count = triangleCount * 3;
				
				// Now unpack all the mesh data
				var outTriangleIndex = 0;
				for (var primitiveIndex = 0; primitiveIndex < array_length(m_loader.m_primitives); ++primitiveIndex)
				{
					var primitive = m_loader.m_primitives[primitiveIndex];
					var primitive_tf = m_loader.m_primitiveTransforms[primitiveIndex];
					var primitive_hasRotation = (primitive_tf[1][0] != 0.0) || (primitive_tf[1][1] != 0.0) || (primitive_tf[1][2] != 0.0) || (primitive_tf[1][3] != 1.0);
					
					var l_POSITION = m_loader.m_accessorData[primitive.attributes.POSITION];
					var l_NORMAL = m_loader.m_accessorData[primitive.attributes.NORMAL];
					var l_TEXCOORD_0 = m_loader.m_accessorData[primitive.attributes.TEXCOORD_0];
					
					var triangleCount = m_loader.m_object.accessors[primitive.indices].count / 3;
					for (var triangleIndex = 0; triangleIndex < triangleCount; ++triangleIndex)
					{
						// Write out the vertex information
						for (var cornerIndex = 0; cornerIndex < 3; ++cornerIndex)
						{
							var index = m_loader.m_accessorData[primitive.indices][triangleIndex * 3 + cornerIndex];
								
							if (kMD2_IsFlatAttributeArrays)
							{
								if (primitive_hasRotation)
								{
									var l_position	= aquat_multiply_avec3(primitive_tf[1], [l_POSITION[index * 3 + 0],	l_POSITION[index * 3 + 1],	l_POSITION[index * 3 + 2]]);
									var l_normal	= aquat_multiply_avec3(primitive_tf[1], [l_NORMAL[index * 3 + 0],	l_NORMAL[index * 3 + 1],	l_NORMAL[index * 3 + 2]]);
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 0] = (l_position[0] + primitive_tf[0][0]) * primitive_tf[2][0];
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 1] = (l_position[2] + primitive_tf[0][2]) * primitive_tf[2][2];
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 2] = (l_position[1] + primitive_tf[0][1]) * primitive_tf[2][1];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 0] = l_normal[0];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 1] = l_normal[2];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 2] = l_normal[1];
								}
								else
								{
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 0] = (l_POSITION[index * 3 + 0] + primitive_tf[0][0]) * primitive_tf[2][0];
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 1] = (l_POSITION[index * 3 + 2] + primitive_tf[0][2]) * primitive_tf[2][2];
									frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 2] = (l_POSITION[index * 3 + 1] + primitive_tf[0][1]) * primitive_tf[2][1];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 0] = l_NORMAL[index * 3 + 0];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 1] = l_NORMAL[index * 3 + 2];
									frame.normals[(outTriangleIndex * 3 + cornerIndex) * 3 + 2] = l_NORMAL[index * 3 + 1];
								}
								frame.texcoords[(outTriangleIndex * 3 + cornerIndex) * 2 + 0] = l_TEXCOORD_0[index * 2 + 0];
								frame.texcoords[(outTriangleIndex * 3 + cornerIndex) * 2 + 1] = l_TEXCOORD_0[index * 2 + 1];
								
								debugLog(kLogVerbose, string(frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 0]));
								debugLog(kLogVerbose, string(frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 1]));
								debugLog(kLogVerbose, string(frame.vertices[(outTriangleIndex * 3 + cornerIndex) * 3 + 2]));
							}
							else
							{
								frame.vertices[outTriangleIndex * 3 + cornerIndex] = array_create(3);
								frame.vertices[outTriangleIndex * 3 + cornerIndex][0] = (l_POSITION[index * 3 + 0] + primitive_tf[0][0]) * primitive_tf[2][0];
								frame.vertices[outTriangleIndex * 3 + cornerIndex][1] = (l_POSITION[index * 3 + 2] + primitive_tf[0][2]) * primitive_tf[2][2];
								frame.vertices[outTriangleIndex * 3 + cornerIndex][2] = (l_POSITION[index * 3 + 1] + primitive_tf[0][1]) * primitive_tf[2][1];
								frame.normals[outTriangleIndex * 3 + cornerIndex] = array_create(3);
								frame.normals[outTriangleIndex * 3 + cornerIndex][0] = l_NORMAL[index * 3 + 0];
								frame.normals[outTriangleIndex * 3 + cornerIndex][1] = l_NORMAL[index * 3 + 2];
								frame.normals[outTriangleIndex * 3 + cornerIndex][2] = l_NORMAL[index * 3 + 1];
								frame.texcoords[outTriangleIndex * 3 + cornerIndex] = array_create(2);
								frame.texcoords[outTriangleIndex * 3 + cornerIndex][0] = l_TEXCOORD_0[index * 2 + 0];
								frame.texcoords[outTriangleIndex * 3 + cornerIndex][1] = l_TEXCOORD_0[index * 2 + 1];
							}
						}
						// End corners
						
						++outTriangleIndex; // Done with the triangle!
					}
				}
				
				// Save frame
				m_frames[frameIndex] = frame;
			}
			return true;
		}
		return false;
	}
	
	/// @function ReadTextures()
	/// @desc Grabs the textures & attempts to create GM-side sprite/texture data for them
	/// @returns {Boolean} success at populating data
	static ReadTextures = function()
	{
		if (m_loader.ExportTextures())
		{
			m_textures = array_create(array_length(m_loader.m_spriteTextures));
			
			// Textures in GLTF are embedded. The loader loads them up.
			for (var i = 0; i < array_length(m_loader.m_spriteTextures); ++i)
			{
				static gltf_texture_count = 0;
				var loaded_texture = ResourceAddTexture("gltf_" + m_modelname + string(gltf_texture_count), m_loader.m_spriteTextures[i]);
				m_textures[i] = loaded_texture;
			}
			
			return true;
		}
		return false;
	}
}