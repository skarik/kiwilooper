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
			debugOut("Invalid file");
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
				m_skins[i] = buffer_read_byte_array(m_blob, 64);
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
				m_tris[i] = {};
				m_tris[i].vertex = array_create(3);
				m_tris[i].vertex[0] = buffer_read(m_blob, buffer_s16);
				m_tris[i].vertex[1] = buffer_read(m_blob, buffer_s16);
				m_tris[i].vertex[2] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st = array_create(3);
				m_tris[i].st[0] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st[1] = buffer_read(m_blob, buffer_s16);
				m_tris[i].st[2] = buffer_read(m_blob, buffer_s16);
				/*	{
					vertex: [buffer_read(m_blob, buffer_s16), buffer_read(m_blob, buffer_s16), buffer_read(m_blob, buffer_s16)],
					st: [buffer_read(m_blob, buffer_s16), buffer_read(m_blob, buffer_s16), buffer_read(m_blob, buffer_s16)],
				};*/
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
				m_frames[frame] = {};
				m_frames[frame].scale = array_create(3);
					m_frames[frame].scale[0] = buffer_read(m_blob, buffer_f32);
					m_frames[frame].scale[1] = buffer_read(m_blob, buffer_f32);
					m_frames[frame].scale[2] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].translate = array_create(3);
					m_frames[frame].translate[0] = buffer_read(m_blob, buffer_f32);
					m_frames[frame].translate[1] = buffer_read(m_blob, buffer_f32);
					m_frames[frame].translate[2] = buffer_read(m_blob, buffer_f32);
				m_frames[frame].name = buffer_read_byte_array(m_blob, 16);
				m_frames[frame].verts = array_create(m_header.num_vertices);
					/*{
					scale: new Vector3(buffer_read(m_blob, buffer_f32), buffer_read(m_blob, buffer_f32), buffer_read(m_blob, buffer_f32)),
					translate: new Vector3(buffer_read(m_blob, buffer_f32), buffer_read(m_blob, buffer_f32), buffer_read(m_blob, buffer_f32)),
					name: buffer_read_byte_array(m_blob, 16),
					verts: array_create(m_header.num_vertices),
				};*/
				for (var i = 0; i < m_header.num_vertices; ++i)
				{
					m_frames[frame].verts[i] = {}; 
					m_frames[frame].verts[i].v = array_create(3);
					m_frames[frame].verts[i].v[0] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].verts[i].v[1] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].verts[i].v[2] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].verts[i].normalIndex = buffer_read(m_blob, buffer_u8);
						/*{
						// Compressed vertex position
						v: [buffer_read(m_blob, buffer_u8), buffer_read(m_blob, buffer_u8), buffer_read(m_blob, buffer_u8)],
						// Normal index
						normalIndex: buffer_read(m_blob, buffer_u8),
					};*/
				}
			}
			return true;
		}
		return false;
	}
}

function AMeshFrame(vertex_count) constructor
{
	vertices	= array_create(vertex_count);
	normals		= array_create(vertex_count);
	texcoords	= array_create(vertex_count);
}

function AMD2FileParser() constructor
{
	m_loader = new AFileMD2Reader();
	m_frames = [];
	
	/// @function GetFrames()
	static GetFrames = function()
	{
		gml_pragma("forceinline");
		return m_frames;
	}
	
	/// @function OpenFile(filepath)
	/// @desc Attempts to open & read the given file as a MD2 model
	static OpenFile = function(filepath)
	{
		if (!m_loader.OpenFile(filepath))
		{
			debugOut("Could not find file \"" + filepath + "\"");
			return false;
		}
		if (!m_loader.ReadHeader())
		{
			debugOut("File header malformed");
			m_loader.CloseFile();
			return false;
		}
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
				
				// Take all the triangles and find their vertices:
				var compressed_frame = m_loader.m_frames[frame];
				
				for (var tri = 0; tri < m_loader.m_header.num_tris; ++tri)
				{
					for (var tri_index = 0; tri_index < 3; ++tri_index)
					{
						var out_vert_index = tri * 3 + tri_index;
						
						var compressed_vertex_index = m_loader.m_tris[tri].vertex[tri_index];
						var compressed_st_index = m_loader.m_tris[tri].st[tri_index];
						
						// 
						//var vert = Vector3FromArray(compressed_frame.verts[compressed_vertex_index].v);
						//vert.multiplyComponentSelf(compressed_frame.scale).addSelf(compressed_frame.translate);
						//m_frames[frame].vertices[out_vert_index] = vert;
						var vert = [compressed_frame.verts[compressed_vertex_index].v[0], compressed_frame.verts[compressed_vertex_index].v[1], compressed_frame.verts[compressed_vertex_index].v[2]];
						vert[0] = vert[0] * compressed_frame.scale[0] + compressed_frame.translate[0];
						vert[1] = vert[1] * compressed_frame.scale[1] + compressed_frame.translate[1];
						vert[2] = vert[2] * compressed_frame.scale[2] + compressed_frame.translate[2];
						m_frames[frame].vertices[out_vert_index] = vert;//Vector3FromArray(vert);//new Vector3(vert[0], vert[1], vert[2]);
						
						//
						var normal = FileMD2LookupNormal(compressed_frame.verts[compressed_vertex_index].normalIndex); // masterpiece line
						m_frames[frame].normals[out_vert_index] = normal;
						
						//
						var st = m_loader.m_st[compressed_st_index];
						var texCoord = [st[0] / m_loader.m_header.skinwidth, st[1] / m_loader.m_header.skinheight];
						m_frames[frame].texcoords[out_vert_index] = texCoord;
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