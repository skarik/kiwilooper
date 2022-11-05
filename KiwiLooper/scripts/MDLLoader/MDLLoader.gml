function AFileMDLHeader() constructor
{
	ident		= 0;
	version		= 0;
	
	scale			= [1, 1, 1];
	translate		= [0, 0, 0];
	boundingradius	= 1.0;
	eyeposition		= [0, 0, 0];
	
	num_skins	= 0;
	skinwidth	= 0;
	skinheight	= 0;
	
	num_verts		= 0;
	num_tris		= 0;
	num_frames		= 0;
	
	synctype	= 0;
	flags		= 0;
	size		= 1.0;
}

function AFileMDLReader() constructor
{
	m_header = new AFileMDLHeader();
	m_blob = null; // buffer of the entire file
	
	m_offset_skins = 0;
	m_offset_texcoords = 0;
	m_offset_tris = 0;
	m_offset_frames = 0;
	
	m_skins = [];
	m_texcoords = [];
	m_tris = [];
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
		
		m_header.scale[0]		= buffer_read(m_blob, buffer_f32);
		m_header.scale[1]		= buffer_read(m_blob, buffer_f32);
		m_header.scale[2]		= buffer_read(m_blob, buffer_f32);
		m_header.translate[0]	= buffer_read(m_blob, buffer_f32);
		m_header.translate[1]	= buffer_read(m_blob, buffer_f32);
		m_header.translate[2]	= buffer_read(m_blob, buffer_f32);
		m_header.boundingradius	= buffer_read(m_blob, buffer_f32);
		m_header.eyeposition[0]	= buffer_read(m_blob, buffer_f32);
		m_header.eyeposition[1]	= buffer_read(m_blob, buffer_f32);
		m_header.eyeposition[2]	= buffer_read(m_blob, buffer_f32);
		
		m_header.num_skins		= buffer_read(m_blob, buffer_s32);
		m_header.skinwidth		= buffer_read(m_blob, buffer_s32);
		m_header.skinheight		= buffer_read(m_blob, buffer_s32);
		
		m_header.num_verts		= buffer_read(m_blob, buffer_s32);
		m_header.num_tris		= buffer_read(m_blob, buffer_s32);
		m_header.num_frames		= buffer_read(m_blob, buffer_s32);
		
		m_header.synctype		= buffer_read(m_blob, buffer_s32);
		m_header.flags			= buffer_read(m_blob, buffer_s32);
		m_header.size			= buffer_read(m_blob, buffer_f32);
		
		if (m_header.ident != 1330660425 ||
			m_header.version != 6)
		{
			debugOut("Invalid file");
			return false;
		}
		
		m_offset_skins = buffer_tell(m_blob);

		return true;
	}
	
	static ReadSkins = function()
	{
		if (m_header.num_skins > 0 && m_offset_skins != 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_offset_skins);
			for (var i = 0; i < m_header.num_skins; ++i)
			{
				m_skins[i] = {};
				
				m_skins[i].group = buffer_read(m_blob, buffer_s32);
				if (m_skins[i].group == 0)
				{
					m_skins[i].data = array_create(m_header.skinwidth * m_header.skinheight);
					for (var pixel = 0; pixel < m_header.skinwidth * m_header.skinheight; ++pixel)
					{
						m_skins[i].data[pixel] = buffer_read(m_blob, buffer_u8);
					}
				}
				else
				{
					m_skins[i].nm = buffer_read(m_blob, buffer_s32);
					if (m_skins[i].nm < 0)
					{
						debugOut("corrupted skin section");
					}
					m_skins[i].time = array_create(m_skins[i].nm);
					for (var subskin = 0; subskin < m_skins[i].nm; ++subskin)
					{
						m_skins[i].time[subskin] = buffer_read(m_blob, buffer_f32);
					}
					m_skins[i].data = array_create(m_skins[i].nm);
					for (var subskin = 0; subskin < m_skins[i].nm; ++subskin)
					{
						m_skins[i].data[subskin] = array_create(m_header.skinwidth * m_header.skinheight);
						for (var pixel = 0; pixel < m_header.skinwidth * m_header.skinheight; ++pixel)
						{
							m_skins[i].data[subskin][pixel] = buffer_read(m_blob, buffer_u8);
						}
					}
				}
			}
			m_offset_texcoords = buffer_tell(m_blob);
			return true;
		}
		return false;
	}
	
	static ReadTexcoords = function()
	{
		if (m_header.num_verts > 0 && m_offset_texcoords != 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_offset_texcoords);
			m_texcoords = array_create(m_header.num_verts);
			for (var i = 0; i < m_header.num_verts; ++i)
			{
				m_texcoords[i] = {};
				m_texcoords[i].onseam = buffer_read(m_blob, buffer_s32);
				m_texcoords[i].s = buffer_read(m_blob, buffer_s32);
				m_texcoords[i].t = buffer_read(m_blob, buffer_s32);
			}
			m_offset_tris = buffer_tell(m_blob);
			return true;
		}
		return false;
	}
	
	static ReadTris = function()
	{
		if (m_header.num_tris > 0 && m_offset_tris != 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_offset_tris);
			m_tris = array_create(m_header.num_tris);
			for (var i = 0; i < m_header.num_tris; ++i)
			{
				m_tris[i] = {};
				m_tris[i].facesfront = buffer_read(m_blob, buffer_s32);
				m_tris[i].vertex = array_create(3);
				m_tris[i].vertex[0] = buffer_read(m_blob, buffer_s32);
				m_tris[i].vertex[1] = buffer_read(m_blob, buffer_s32);
				m_tris[i].vertex[2] = buffer_read(m_blob, buffer_s32);
			}
			m_offset_frames = buffer_tell(m_blob);
			return true;
		}
		return false;
	}

	static ReadFrames = function()
	{
		if (m_header.num_frames > 0 && m_offset_frames != 0)
		{
			buffer_seek(m_blob, buffer_seek_start, m_offset_frames);
			m_frames = array_create(m_header.num_frames);
			for (var frame = 0; frame < m_header.num_frames; ++frame)
			{
				m_frames[frame] = {};
				m_frames[frame].type = buffer_read(m_blob, buffer_s32);
				// Simple frame
				if (m_frames[frame].type == 0)
				{
					m_frames[frame].bboxmin = array_create(3);
					m_frames[frame].bboxmin[0] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmin[1] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmin[2] = buffer_read(m_blob, buffer_u8);
					/*m_frames[frame].bboxmin[3] =*/ buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax = array_create(3);
					m_frames[frame].bboxmax[0] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax[1] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax[2] = buffer_read(m_blob, buffer_u8);
					/*m_frames[frame].bboxmax[3] =*/ buffer_read(m_blob, buffer_u8);
					m_frames[frame].name = buffer_read_byte_array_as_terminated_string(m_blob, 16);
					m_frames[frame].verts = array_create(m_header.num_verts);
					for (var i = 0; i < m_header.num_verts; ++i)
					{
						m_frames[frame].verts[i] = {};
						m_frames[frame].verts[i].v = array_create(3);
						m_frames[frame].verts[i].v[0] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].v[1] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].v[2] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].verts[i].normalIndex = buffer_read(m_blob, buffer_u8);
					}
				}
				// Compound frame
				else
				{
					m_frames[frame].nm = buffer_read(m_blob, buffer_s32);
					if (m_frames[frame].nm < 0)
					{
						debugOut("corrupted frame section");
						return false;
					}
					m_frames[frame].bboxmin[0] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmin[1] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmin[2] = buffer_read(m_blob, buffer_u8);
					/*m_frames[frame].bboxmin[3] =*/ buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax = array_create(3);
					m_frames[frame].bboxmax[0] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax[1] = buffer_read(m_blob, buffer_u8);
					m_frames[frame].bboxmax[2] = buffer_read(m_blob, buffer_u8);
					/*m_frames[frame].bboxmax[3] =*/ buffer_read(m_blob, buffer_u8);
					m_frames[frame].times = array_create(m_frames[frame].nm);
					for (var subframe = 0; subframe < m_frames[frame].nm; ++subframe)
					{
						m_frames[frame].times[subframe] = buffer_read(m_blob, buffer_f32);
					}
					m_frames[frame].frames = array_create(m_frames[frame].nm);
					for (var subframe = 0; subframe < m_frames[frame].nm; ++subframe)
					{
						m_frames[frame].frames[subframe] = {};
						m_frames[frame].frames[subframe].bboxmin = array_create(3);
						m_frames[frame].frames[subframe].bboxmin[0] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].bboxmin[1] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].bboxmin[2] = buffer_read(m_blob, buffer_u8);
						/*m_frames[frame].bboxmin[3] =*/ buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].bboxmax = array_create(3);
						m_frames[frame].frames[subframe].bboxmax[0] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].bboxmax[1] = buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].bboxmax[2] = buffer_read(m_blob, buffer_u8);
						/*m_frames[frame].bboxmax[3] =*/ buffer_read(m_blob, buffer_u8);
						m_frames[frame].frames[subframe].name = buffer_read_byte_array_as_terminated_string(m_blob, 16);
						m_frames[frame].frames[subframe].verts = array_create(m_header.num_verts);
						for (var i = 0; i < m_header.num_verts; ++i)
						{
							m_frames[frame].frames[subframe].verts[i] = {};
							m_frames[frame].frames[subframe].verts[i].v = array_create(3);
							m_frames[frame].frames[subframe].verts[i].v[0] = buffer_read(m_blob, buffer_u8);
							m_frames[frame].frames[subframe].verts[i].v[1] = buffer_read(m_blob, buffer_u8);
							m_frames[frame].frames[subframe].verts[i].v[2] = buffer_read(m_blob, buffer_u8);
							m_frames[frame].frames[subframe].verts[i].normalIndex = buffer_read(m_blob, buffer_u8);
						}
					}
				}
			}
			return true;
		}
		return false;
	}
}

#macro kFileLoadStateNotLoaded	0
#macro kFileLoadStateSuccess	1
#macro kFileLoadStateFailed		-1

function AFileLoadStateTracker(load_call) constructor
{
	m_call = load_call;
	m_loadstate = kFileLoadStateNotLoaded;
	static Load = function()
	{
		if (m_loadstate == kFileLoadStateNotLoaded)
		{
			m_loadstate = m_call() ? kFileLoadStateSuccess : kFileLoadStateFailed;
		}
		return m_loadstate == kFileLoadStateSuccess;
	}
}

function AMDLFileParser() constructor
{
	m_loader = new AFileMDLReader();
	m_frames = [];
	m_textures = [];
	
	// Loaders used for tracking which parts have already been read in
	m_lsSkins = null;
	m_lsTexcoords =null; 
	m_lsTris = null;
	m_lsFrames = null;
	static _SetupLoaders = function()
	{
		m_lsSkins = new AFileLoadStateTracker(method(m_loader, m_loader.ReadSkins));
		m_lsTexcoords = new AFileLoadStateTracker(method(m_loader, m_loader.ReadTexcoords));
		m_lsTris = new AFileLoadStateTracker(method(m_loader, m_loader.ReadTris));
		m_lsFrames = new AFileLoadStateTracker(method(m_loader, m_loader.ReadFrames));
	}
	_SetupLoaders();
	
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
		_SetupLoaders();
	}
	
	/// @function ReadFrames()
	/// @desc Takes the MD2 data and decompresses it into a tri-list that can be rendered.
	/// @returns {Boolean} success at populating data
	static ReadFrames = function()
	{
		if (m_lsSkins.Load() && m_lsTexcoords.Load() && m_lsTris.Load() && m_lsFrames.Load())
		{
			m_frames = array_create(m_loader.m_header.num_frames);
			for (var frame = 0; frame < m_loader.m_header.num_frames; ++frame)
			{
				// Create the mesh we need to submit for this frame
				m_frames[frame] = new AMeshFrame(m_loader.m_header.num_tris * 3);
				
				// Take all the triangles and find their vertices:
				var compressed_frame = m_loader.m_frames[frame];
				
				if (compressed_frame.type == 0)
				{
					for (var tri = 0; tri < m_loader.m_header.num_tris; ++tri)
					{
						for (var tri_index = 0; tri_index < 3; ++tri_index)
						{
							var out_vert_index = tri * 3 + tri_index;
						
							var compressed_vertex_index = m_loader.m_tris[tri].vertex[tri_index];
						
							// 
							var vert = [compressed_frame.verts[compressed_vertex_index].v[0], compressed_frame.verts[compressed_vertex_index].v[1], compressed_frame.verts[compressed_vertex_index].v[2]];
							vert[0] = vert[0] * m_loader.m_header.scale[0] + m_loader.m_header.translate[0];
							vert[1] = vert[1] * m_loader.m_header.scale[1] + m_loader.m_header.translate[1];
							vert[2] = vert[2] * m_loader.m_header.scale[2] + m_loader.m_header.translate[2];
							m_frames[frame].vertices[out_vert_index] = vert;
						
							//
							var normal = FileMD2LookupNormal(compressed_frame.verts[compressed_vertex_index].normalIndex);
							m_frames[frame].normals[out_vert_index] = normal;
						
							//
							var st = m_loader.m_texcoords[compressed_vertex_index];
							var texCoord = [(st.s + 0.5) / m_loader.m_header.skinwidth, (st.t + 0.5) / m_loader.m_header.skinheight];
							if (!m_loader.m_tris[tri].facesfront && st.onseam) // Fix backface seams
							{
								texCoord[0] += 0.5;
							}
							m_frames[frame].texcoords[out_vert_index] = texCoord;
						}
					}
				}
				else
				{
					debugMessage("working with group frame " + string(frame) + " with " + string(compressed_frame.nm) + " subframes");
					for (var subframe = 0; subframe < compressed_frame.nm; ++subframe)
					{
						show_error("unsupported group frame " + string(frame), true);
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
		if (m_lsSkins.Load())
		{
			// We have the texture, let's convert to RGB
			var compressed_skin = m_loader.m_skins[0];
			
			if (compressed_skin.group == 0)
			{
				var temp_canvas = surface_create(m_loader.m_header.skinwidth, m_loader.m_header.skinheight);
				surface_set_target(temp_canvas);
				gpu_set_blendenable(false);
				
				draw_clear_alpha(c_white, 0.0);
				for (var dy = 0; dy < m_loader.m_header.skinheight; ++dy)
				{
					for (var dx = 0; dx < m_loader.m_header.skinwidth; ++dx)
					{
						var flat_index = dx + dy * m_loader.m_header.skinwidth ;
						var rgb = FileMDLLookupColorQuake(compressed_skin.data[flat_index]);
						
						draw_set_color(make_color_rgb(rgb[0], rgb[1], rgb[2])); 
						draw_point(dx, dy);
					}
				}
				
				gpu_set_blendenable(true);
				surface_reset_target();
			
				static mdl_texture_count = 0;
				var new_sprite = sprite_create_from_surface(temp_canvas, 0, 0, m_loader.m_header.skinwidth,  m_loader.m_header.skinheight, false, false, 0, 0);
				m_textures[0] = ResourceAddTexture("MDLTEX"+string(mdl_texture_count++), new_sprite);
				ResourceAddReference(loaded_texture); // Add ref until we're done with it.
			
				surface_free(temp_canvas);
			}
			else
			{
				show_error("unsupported animated skin " + string(0), true);
			}
			
			return true;
		}
		return false;
	}
}