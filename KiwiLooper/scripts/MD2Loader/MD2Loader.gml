#macro kMD2_IsBitpackedVertexRead true
#macro kMD2_IsFlatAttributeArrays true

function AFileMD2Header() constructor
{
	ident		= 0;
	version		= 0;
	
	skinwidth	= 0;
	skinheight	= 0;
	
	framesize	= 0;
	
	num_skins		= 0;
	num_vertices	= 0;
	num_st			= 0;
	num_tris		= 0;
	num_glcmds		= 0;
	num_frames		= 0;
	
	offset_skins	= 0;
	offset_st		= 0;
	offset_tris		= 0;
	offset_frames	= 0;
	offset_glcmds	= 0;
	offset_end		= 0;
}

function AFileMD2Reader() constructor
{
	m_header = new AFileMD2Header();
	m_blob = null; // buffer of the entire file
	
	m_skins = [];
	m_st = [];
	m_tris = [];
	m_glcmds = [];
	m_frames = [];
	
	static OpenFile = function(path) 
	{
		m_blob = buffer_load(path);
		return m_blob != -1;
	}
	static CloseFile = function()
	{
		buffer_delete(m_blob);
		m_blob = null;
	}
	
	static ReadHeader = function()
	{
		buffer_seek(m_blob, buffer_seek_start, 0);
		
		m_header.ident			= buffer_read(m_blob, buffer_s32);
		m_header.version		= buffer_read(m_blob, buffer_s32);
		
		m_header.skinwidth		= buffer_read(m_blob, buffer_s32);
		m_header.skinheight		= buffer_read(m_blob, buffer_s32);
		
		m_header.framesize		= buffer_read(m_blob, buffer_s32);
		
		m_header.num_skins		= buffer_read(m_blob, buffer_s32);
		m_header.num_vertices	= buffer_read(m_blob, buffer_s32);
		m_header.num_st			= buffer_read(m_blob, buffer_s32);
		m_header.num_tris		= buffer_read(m_blob, buffer_s32);
		m_header.num_glcmds		= buffer_read(m_blob, buffer_s32);
		m_header.num_frames		= buffer_read(m_blob, buffer_s32);
		
		m_header.offset_skins	= buffer_read(m_blob, buffer_s32);
		m_header.offset_st		= buffer_read(m_blob, buffer_s32);
		m_header.offset_tris	= buffer_read(m_blob, buffer_s32);
		m_header.offset_frames	= buffer_read(m_blob, buffer_s32);
		m_header.offset_glcmds	= buffer_read(m_blob, buffer_s32);
		m_header.offset_end		= buffer_read(m_blob, buffer_s32);
		
		if (m_header.ident != 844121161 ||
			m_header.version != 8)
		{
			debugLog(kLogError, "Invalid file");
			return false;
		}
		
		return true;
	}
	
	static ReadSkins = function()
	{
		if (m_header.offset_skins != 0 && m_header.num_skins > 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_header.offset_skins);
			m_skins = array_create(m_header.num_skins);
			for (var i = 0; i < m_header.num_skins; ++i)
			{
				m_skins[i] = buffer_read_byte_array_as_terminated_string(m_blob, 64);
			}
			return true;
		}
		return false;
	}
	static ReadSt = function()
	{
		if (m_header.offset_st != 0 && m_header.num_st > 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_header.offset_st);
			m_st = array_create(m_header.num_st);
			for (var i = 0; i < m_header.num_st; ++i)
			{
				/*m_st[i] = new Vector2(
					buffer_read(m_blob, buffer_s16),
					buffer_read(m_blob, buffer_s16)
					);*/
				m_st[i] = array_create(2);
				m_st[i][0] = buffer_read(m_blob, buffer_s16);
				m_st[i][1] = buffer_read(m_blob, buffer_s16);
			}
			return true;
		}
		return false;
	}
	static ReadTriangles = function()
	{
		if (m_header.offset_tris != 0 && m_header.num_tris > 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_header.offset_tris);
			m_tris = array_create(m_header.num_tris);
			for (var i = 0; i < m_header.num_tris; ++i)
			{
				m_tris[i] = {
					vertex:	array_create(3, 0),
					st:		array_create(3, 0),
				};
				m_tris[i].vertex[0] = buffer_read(m_blob, buffer_s16);
				m_tris[i].vertex[1] = buffer_read(m_blob, buffer_s16);
				m_tris[i].vertex[2] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st[0] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st[1] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st[2] = buffer_read(m_blob, buffer_s16);
			}
			return true;
		}
		return false;
	}
	static ReadGlCmds = function()
	{
		if (m_header.offset_glcmds != 0 && m_header.num_glcmds > 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_header.offset_glcmds);
			m_glcmds = array_create(m_header.num_glcmds);
			for (var i = 0; i < m_header.num_glcmds; ++i)
			{
				m_glcmds[i] = buffer_read(m_blob, buffer_s32);
			}
			return true;
		}
		return false;
	}
	static ReadFrames = function()
	{
		if (m_header.offset_frames != 0 && m_header.num_frames > 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_header.offset_frames);
			m_frames = array_create(m_header.num_frames);
			for (var frame = 0; frame < m_header.num_frames; ++frame)
			{
				m_frames[frame] = {
					scale:		array_create(3, 0.0),
					translate:	array_create(3, 0.0),
					name:		"",
					verts:		array_create(m_header.num_vertices, 0),
				};
				m_frames[frame].scale[0] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].scale[1] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].scale[2] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].translate[0] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].translate[1] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].translate[2] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].name = buffer_read_byte_array_as_terminated_string(m_blob, 16);
				for (var i = 0; i < m_header.num_vertices; ++i)
				{
					if (kMD2_IsBitpackedVertexRead)
					{
						m_frames[frame].verts[i] = buffer_read(m_blob, buffer_u32);
					}
					else
					{
						m_frames[frame].verts[i] = {
							v:	array_create(3, 0),
							normalIndex:	0,
						};
						m_frames[frame].verts[i].v[0] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].v[1] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].v[2] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].normalIndex = buffer_read(m_blob, buffer_u8);
					}
				}
			}
			return true;
		}
		return false;
	}
}

function AMeshFrame(vertex_count) constructor
{
	count = 0;
	if (kMD2_IsFlatAttributeArrays)
	{
		vertices	= array_create(vertex_count * 3, 0.0);
		normals		= array_create(vertex_count * 3, 0.0);
		texcoords	= array_create(vertex_count * 2, 0.0);
	}
	else
	{
		vertices	= array_create(vertex_count);
		normals		= array_create(vertex_count);
		texcoords	= array_create(vertex_count);
	}
}

function AMD2FileParser() constructor
{
	m_loader = new AFileMD2Reader();
	m_frames = [];
	m_textures = [];
	m_frameCount = 0;
	
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
	/// @desc Attempts to open & read the given file as a MD2 model
	static OpenFile = function(filepath)
	{
		debugLog(kLogWarning, "Note: MD2 loadstate is not tracked, be careful when loading");
		if (!m_loader.OpenFile(filepath))
		{
			debugLog(kLogError, "Could not find file \"" + filepath + "\"");
			return false;
		}
		if (!m_loader.ReadHeader())
		{
			debugLog(kLogError, "File header malformed");
			m_loader.CloseFile();
			return false;
		}
		m_frameCount = m_loader.m_header.num_frames;
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
		if (m_loader.ReadFrames() && m_loader.ReadTriangles() && m_loader.ReadSt()) // todo: ensure these are read only once
		{
			m_frames = array_create(m_loader.m_header.num_frames);
			for (var frame = 0; frame < m_loader.m_header.num_frames; ++frame)
			{
				// Create the mesh we need to submit for this frame
				m_frames[frame] = new AMeshFrame(m_loader.m_header.num_tris * 3);
				
				// Set up initial output frame info
				var output_frame = m_frames[frame];
				output_frame.count = m_loader.m_header.num_tris * 3;
				
				// Take all the triangles and find their vertices:
				var compressed_frame = m_loader.m_frames[frame];
				
				for (var tri = 0; tri < m_loader.m_header.num_tris; ++tri)
				{
					for (var tri_index = 0; tri_index < 3; ++tri_index)
					{
						var out_vert_index = tri * 3 + tri_index;
						
						var compressed_vertex_index	= m_loader.m_tris[tri].vertex[tri_index];
						var compressed_st_index		= m_loader.m_tris[tri].st[tri_index];
						
						// Load in flat arrays
						if (kMD2_IsFlatAttributeArrays)
						{
							var out_vert_index2 = out_vert_index * 2;
							var out_vert_index3 = out_vert_index * 3;
							
							//
							output_frame.vertices[out_vert_index3+0]
								= ((compressed_frame.verts[compressed_vertex_index] & 0x0000FF))		* compressed_frame.scale[0] + compressed_frame.translate[0];
							output_frame.vertices[out_vert_index3+1]
								= ((compressed_frame.verts[compressed_vertex_index] & 0x00FF00) >> 8)	* compressed_frame.scale[1] + compressed_frame.translate[1];
							output_frame.vertices[out_vert_index3+2]
								= ((compressed_frame.verts[compressed_vertex_index] & 0xFF0000) >> 16)	* compressed_frame.scale[2] + compressed_frame.translate[2];
							
							//
							var normal = FileMD2LookupNormal((compressed_frame.verts[compressed_vertex_index] & 0xFF000000) >> 24);
							output_frame.normals[out_vert_index3+0] = normal[0];
							output_frame.normals[out_vert_index3+1] = normal[1];
							output_frame.normals[out_vert_index3+2] = normal[2];
							
							//
							var st = m_loader.m_st[compressed_st_index];
							output_frame.texcoords[out_vert_index2+0] = real(st[0]) / m_loader.m_header.skinwidth;
							output_frame.texcoords[out_vert_index2+1] = real(st[1]) / m_loader.m_header.skinheight;
						}
						// Load into arrays-in-arrays
						else
						{
							// 
							var vert;
							if (kMD2_IsBitpackedVertexRead)
							{
								vert = [
									(compressed_frame.verts[compressed_vertex_index] & 0x0000FF),
									(compressed_frame.verts[compressed_vertex_index] & 0x00FF00) >> 8, 
									(compressed_frame.verts[compressed_vertex_index] & 0xFF0000) >> 16
									];
							}
							else
							{
								vert = [
									compressed_frame.verts[compressed_vertex_index].v[0],
									compressed_frame.verts[compressed_vertex_index].v[1],
									compressed_frame.verts[compressed_vertex_index].v[2]
									];
							}
							vert[0] = vert[0] * compressed_frame.scale[0] + compressed_frame.translate[0];
							vert[1] = vert[1] * compressed_frame.scale[1] + compressed_frame.translate[1];
							vert[2] = vert[2] * compressed_frame.scale[2] + compressed_frame.translate[2];
							output_frame.vertices[out_vert_index] = vert;
						
							//
							var normal;
							if (kMD2_IsBitpackedVertexRead)
							{
								normal = FileMD2LookupNormal((compressed_frame.verts[compressed_vertex_index] & 0xFF000000) >> 24);
							}
							else
							{
								normal = FileMD2LookupNormal(compressed_frame.verts[compressed_vertex_index].normalIndex);
							}
							output_frame.normals[out_vert_index] = normal;
						
							//
							var st = m_loader.m_st[compressed_st_index];
							var texCoord = [real(st[0]) / m_loader.m_header.skinwidth, real(st[1]) / m_loader.m_header.skinheight];
							output_frame.texcoords[out_vert_index] = texCoord;
						}
					}
				}
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
		// TODO: ensure we're only reading once, so we don't have dangling texture references.
		if (m_loader.ReadSkins())
		{
			// Skins in MD2 are just file names - which makes loading pretty much trivial
			for (var i = 0; i < m_loader.m_header.num_skins; ++i)
			{
				// TODO error handle missing files better
				var loaded_texture = ResourceLoadTexture(m_loader.m_skins[i], m_loader.m_header.skinwidth, m_loader.m_header.skinheight);
				if (!is_undefined(loaded_texture))
				{
					m_textures[i] = loaded_texture;
					ResourceAddReference(loaded_texture); // Add ref until we're done with it.
				}
				else
				{
					debugLog(kLogError, "Could not find MD2 skin with filename \"" + m_loader.m_skins[i] + "\"");
					m_textures[i] = undefined; // TODO show this as error
				}
			}
			return true;
		}
		return false;
	}
}


function FileMD2LookupNormal(index)
{
	static normalTable = [
		[ -0.525731,  0.000000,  0.850651 ], 
		[ -0.442863,  0.238856,  0.864188 ], 
		[ -0.295242,  0.000000,  0.955423 ], 
		[ -0.309017,  0.500000,  0.809017 ], 
		[ -0.162460,  0.262866,  0.951056 ], 
		[  0.000000,  0.000000,  1.000000 ], 
		[  0.000000,  0.850651,  0.525731 ], 
		[ -0.147621,  0.716567,  0.681718 ], 
		[  0.147621,  0.716567,  0.681718 ], 
		[  0.000000,  0.525731,  0.850651 ], 
		[  0.309017,  0.500000,  0.809017 ], 
		[  0.525731,  0.000000,  0.850651 ], 
		[  0.295242,  0.000000,  0.955423 ], 
		[  0.442863,  0.238856,  0.864188 ], 
		[  0.162460,  0.262866,  0.951056 ], 
		[ -0.681718,  0.147621,  0.716567 ], 
		[ -0.809017,  0.309017,  0.500000 ], 
		[ -0.587785,  0.425325,  0.688191 ], 
		[ -0.850651,  0.525731,  0.000000 ], 
		[ -0.864188,  0.442863,  0.238856 ], 
		[ -0.716567,  0.681718,  0.147621 ], 
		[ -0.688191,  0.587785,  0.425325 ], 
		[ -0.500000,  0.809017,  0.309017 ], 
		[ -0.238856,  0.864188,  0.442863 ], 
		[ -0.425325,  0.688191,  0.587785 ], 
		[ -0.716567,  0.681718, -0.147621 ], 
		[ -0.500000,  0.809017, -0.309017 ], 
		[ -0.525731,  0.850651,  0.000000 ], 
		[  0.000000,  0.850651, -0.525731 ], 
		[ -0.238856,  0.864188, -0.442863 ], 
		[  0.000000,  0.955423, -0.295242 ], 
		[ -0.262866,  0.951056, -0.162460 ], 
		[  0.000000,  1.000000,  0.000000 ], 
		[  0.000000,  0.955423,  0.295242 ], 
		[ -0.262866,  0.951056,  0.162460 ], 
		[  0.238856,  0.864188,  0.442863 ], 
		[  0.262866,  0.951056,  0.162460 ], 
		[  0.500000,  0.809017,  0.309017 ], 
		[  0.238856,  0.864188, -0.442863 ], 
		[  0.262866,  0.951056, -0.162460 ], 
		[  0.500000,  0.809017, -0.309017 ], 
		[  0.850651,  0.525731,  0.000000 ], 
		[  0.716567,  0.681718,  0.147621 ], 
		[  0.716567,  0.681718, -0.147621 ], 
		[  0.525731,  0.850651,  0.000000 ], 
		[  0.425325,  0.688191,  0.587785 ], 
		[  0.864188,  0.442863,  0.238856 ], 
		[  0.688191,  0.587785,  0.425325 ], 
		[  0.809017,  0.309017,  0.500000 ], 
		[  0.681718,  0.147621,  0.716567 ], 
		[  0.587785,  0.425325,  0.688191 ], 
		[  0.955423,  0.295242,  0.000000 ], 
		[  1.000000,  0.000000,  0.000000 ], 
		[  0.951056,  0.162460,  0.262866 ], 
		[  0.850651, -0.525731,  0.000000 ], 
		[  0.955423, -0.295242,  0.000000 ], 
		[  0.864188, -0.442863,  0.238856 ], 
		[  0.951056, -0.162460,  0.262866 ], 
		[  0.809017, -0.309017,  0.500000 ], 
		[  0.681718, -0.147621,  0.716567 ], 
		[  0.850651,  0.000000,  0.525731 ], 
		[  0.864188,  0.442863, -0.238856 ], 
		[  0.809017,  0.309017, -0.500000 ], 
		[  0.951056,  0.162460, -0.262866 ], 
		[  0.525731,  0.000000, -0.850651 ], 
		[  0.681718,  0.147621, -0.716567 ], 
		[  0.681718, -0.147621, -0.716567 ], 
		[  0.850651,  0.000000, -0.525731 ], 
		[  0.809017, -0.309017, -0.500000 ], 
		[  0.864188, -0.442863, -0.238856 ], 
		[  0.951056, -0.162460, -0.262866 ], 
		[  0.147621,  0.716567, -0.681718 ], 
		[  0.309017,  0.500000, -0.809017 ], 
		[  0.425325,  0.688191, -0.587785 ], 
		[  0.442863,  0.238856, -0.864188 ], 
		[  0.587785,  0.425325, -0.688191 ], 
		[  0.688191,  0.587785, -0.425325 ], 
		[ -0.147621,  0.716567, -0.681718 ], 
		[ -0.309017,  0.500000, -0.809017 ], 
		[  0.000000,  0.525731, -0.850651 ], 
		[ -0.525731,  0.000000, -0.850651 ], 
		[ -0.442863,  0.238856, -0.864188 ], 
		[ -0.295242,  0.000000, -0.955423 ], 
		[ -0.162460,  0.262866, -0.951056 ], 
		[  0.000000,  0.000000, -1.000000 ], 
		[  0.295242,  0.000000, -0.955423 ], 
		[  0.162460,  0.262866, -0.951056 ], 
		[ -0.442863, -0.238856, -0.864188 ], 
		[ -0.309017, -0.500000, -0.809017 ], 
		[ -0.162460, -0.262866, -0.951056 ], 
		[  0.000000, -0.850651, -0.525731 ], 
		[ -0.147621, -0.716567, -0.681718 ], 
		[  0.147621, -0.716567, -0.681718 ], 
		[  0.000000, -0.525731, -0.850651 ], 
		[  0.309017, -0.500000, -0.809017 ], 
		[  0.442863, -0.238856, -0.864188 ], 
		[  0.162460, -0.262866, -0.951056 ], 
		[  0.238856, -0.864188, -0.442863 ], 
		[  0.500000, -0.809017, -0.309017 ], 
		[  0.425325, -0.688191, -0.587785 ], 
		[  0.716567, -0.681718, -0.147621 ], 
		[  0.688191, -0.587785, -0.425325 ], 
		[  0.587785, -0.425325, -0.688191 ], 
		[  0.000000, -0.955423, -0.295242 ], 
		[  0.000000, -1.000000,  0.000000 ], 
		[  0.262866, -0.951056, -0.162460 ], 
		[  0.000000, -0.850651,  0.525731 ], 
		[  0.000000, -0.955423,  0.295242 ], 
		[  0.238856, -0.864188,  0.442863 ], 
		[  0.262866, -0.951056,  0.162460 ], 
		[  0.500000, -0.809017,  0.309017 ], 
		[  0.716567, -0.681718,  0.147621 ], 
		[  0.525731, -0.850651,  0.000000 ], 
		[ -0.238856, -0.864188, -0.442863 ], 
		[ -0.500000, -0.809017, -0.309017 ], 
		[ -0.262866, -0.951056, -0.162460 ], 
		[ -0.850651, -0.525731,  0.000000 ], 
		[ -0.716567, -0.681718, -0.147621 ], 
		[ -0.716567, -0.681718,  0.147621 ], 
		[ -0.525731, -0.850651,  0.000000 ], 
		[ -0.500000, -0.809017,  0.309017 ], 
		[ -0.238856, -0.864188,  0.442863 ], 
		[ -0.262866, -0.951056,  0.162460 ], 
		[ -0.864188, -0.442863,  0.238856 ], 
		[ -0.809017, -0.309017,  0.500000 ], 
		[ -0.688191, -0.587785,  0.425325 ], 
		[ -0.681718, -0.147621,  0.716567 ], 
		[ -0.442863, -0.238856,  0.864188 ], 
		[ -0.587785, -0.425325,  0.688191 ], 
		[ -0.309017, -0.500000,  0.809017 ], 
		[ -0.147621, -0.716567,  0.681718 ], 
		[ -0.425325, -0.688191,  0.587785 ], 
		[ -0.162460, -0.262866,  0.951056 ], 
		[  0.442863, -0.238856,  0.864188 ], 
		[  0.162460, -0.262866,  0.951056 ], 
		[  0.309017, -0.500000,  0.809017 ], 
		[  0.147621, -0.716567,  0.681718 ], 
		[  0.000000, -0.525731,  0.850651 ], 
		[  0.425325, -0.688191,  0.587785 ], 
		[  0.587785, -0.425325,  0.688191 ], 
		[  0.688191, -0.587785,  0.425325 ], 
		[ -0.955423,  0.295242,  0.000000 ], 
		[ -0.951056,  0.162460,  0.262866 ], 
		[ -1.000000,  0.000000,  0.000000 ], 
		[ -0.850651,  0.000000,  0.525731 ], 
		[ -0.955423, -0.295242,  0.000000 ], 
		[ -0.951056, -0.162460,  0.262866 ], 
		[ -0.864188,  0.442863, -0.238856 ], 
		[ -0.951056,  0.162460, -0.262866 ], 
		[ -0.809017,  0.309017, -0.500000 ], 
		[ -0.864188, -0.442863, -0.238856 ], 
		[ -0.951056, -0.162460, -0.262866 ], 
		[ -0.809017, -0.309017, -0.500000 ], 
		[ -0.681718,  0.147621, -0.716567 ], 
		[ -0.681718, -0.147621, -0.716567 ], 
		[ -0.850651,  0.000000, -0.525731 ], 
		[ -0.688191,  0.587785, -0.425325 ], 
		[ -0.587785,  0.425325, -0.688191 ], 
		[ -0.425325,  0.688191, -0.587785 ], 
		[ -0.425325, -0.688191, -0.587785 ], 
		[ -0.587785, -0.425325, -0.688191 ], 
		[ -0.688191, -0.587785, -0.425325 ]
	];
	
	return normalTable[index];
}