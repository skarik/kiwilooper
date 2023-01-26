#macro kUi3BuildModeTextureAndMesh	0

/// @function Ui3Renderer(buildUIFunction) constructor
function Ui3Renderer(buildUIFunction) constructor
{
	m_buildUiCall = buildUIFunction;
	
	m_heldState = {
		atlas_info:			undefined,
		texture_surface:	undefined,
		mesh:				undefined,
	};
	
	static Step = function()
	{
		// Recreate needed states for this frame
		if (is_undefined(m_heldState.atlas_info))
		{
			m_heldState.atlas_info = new ARectFitter(1024, 1024);
		}
		m_heldState.atlas_info.Clear();
		
		// Create a new surface for this frame (we don't reuse surface to try to take advantage of GMS's reuse)
		if (!is_undefined(m_heldState.texture_surface) && surface_exists(m_heldState.texture_surface))
		{
			surface_free(m_heldState.texture_surface);
		}
		m_heldState.texture_surface = surface_create(1024, 1024);
		
		// Set up mesh for building
		if (is_undefined(m_heldState.mesh))
		{
			m_heldState.mesh = meshb_CreateEmptyMesh();
		}
		// TODO: Set up the mesh to build
		
		// Build the UI & mesh
		m_buildUiCall({
			build_mode:	kUi3BuildModeTextureAndMesh,
			atlas_info:	m_heldState.atlas_info,
			surface:	m_heldState.texture_surface,
			mesh:		m_heldState.mesh,
			});
	}
	
	static Draw = function()
	{
		// If we have everything we need to draw, then just draw
		if (!is_undefined(m_heldState.texture_surface) && surface_exists(m_heldState.texture_surface)
			&& !is_undefined(m_heldState.mesh))
		{
			// Set identity so we're true to the rendering coords
			matrix_set(matrix_world, matrix_build_identity());
			// Submit normal-like
			vertex_submit(m_heldState.mesh, pr_trianglelist, surface_get_texture(m_heldState.texture_surface));
		}
	}
	
	static Free = function()
	{
		// Free the GPU resources:
		
		if (!is_undefined(m_heldState.mesh))
		{
			meshB_Cleanup(m_heldState.mesh);
			m_heldState.mesh = undefined;
		}
		
		if (!is_undefined(m_heldState.texture_surface) && surface_exists(m_heldState.texture_surface))
		{
			surface_free(m_heldState.texture_surface);
		}
		
		// Free other structures:
		
		if (!is_undefined(m_heldState.atlas_info))
		{
			m_heldState.atlas_info.Clear();
			delete m_heldState.atlas_info;
			m_heldState.atlas_info = undefined;
		}
		
		delete m_heldState;
	}
}

//=============================================================================

/// @function Ui3Begin(build_info)
function Ui3Begin(build_info)
{
	if (build_info.build_mode == kUi3BuildModeTextureAndMesh)
	{
		surface_set_target(build_info.surface);
		
		// Clear surface now
		draw_clear_alpha(c_white, 0.0);
		
		// Set up mesh for editing
		meshb_BeginEdit(build_info.mesh);
		
		return {
			build_mode:		build_info.build_mode,
			surface:		build_info.surface,
			atlas:			build_info.atlas_info,
			mesh:			build_info.mesh,
		};
	}
	else
	{
		show_error("Invalid call to Ui3Begin(). build_mode must be passed by calling builder.", true);
	}
}
/// @function Ui3End(context)
function Ui3End(context)
{
	if (context.build_mode == kUi3BuildModeTextureAndMesh)
	{
		// Finish mesh
		meshb_End(context.mesh);
		
		// Finish texture
		surface_reset_target();
	}
	else
	{
		show_error("Invalid call to Ui3Begin(). build_mode must be passed by calling builder.", true);
	}
}

//=============================================================================

/// @function Ui3Tex_Text(context, text)
/// @desc Makes a texture with the given content.
function Ui3Tex_Text(context, text)
{
	var old_halign = draw_get_halign();
	var old_valign = draw_get_valign();
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var pixel_width = string_width(text);
	var pixel_height = string_height(text);
	
	var placement_index = context.atlas.AddRect(pixel_width, pixel_height, undefined);
	var placement_uvs = context.atlas.GetUVs(placement_index);
	placement_uvs[5] = pixel_width;
	placement_uvs[6] = pixel_height;
	
	var placement_pos = context.atlas.GetUnscaledPosition(placement_index);
	
	// Draw text, assuming we're using the surface now
	draw_text(placement_pos[0], placement_pos[1], text);
	
	draw_set_halign(old_halign);
	draw_set_valign(old_valign);
	
	return placement_uvs;
}

//=============================================================================

/// @function Ui3Shape_Billboard(context, tex, x, y, z, xscale=1.0, yscale=1.0, rotation=0.0, color=c_white, alpha=1.0)
/// @desc Makes a mesh with the given context and texture
function Ui3Shape_Billboard(context, tex, x, y, z, xscale=1.0, yscale=1.0, rotation=0.0, color=c_white, alpha=1.0)
{
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var cross_x = frontface_direction.cross(Vector3FromArray(o_Camera3D.m_viewUp));
	var cross_y = frontface_direction.cross(cross_x);
	
	cross_x.normalize().multiplySelf(-tex[5] * xscale);
	cross_y.normalize().multiplySelf( tex[6] * yscale);
	
	// Add the quad
	MeshbAddQuadUVs(
		context.mesh,
		color, alpha,
		cross_x,
		cross_y,
		tex,
		new Vector3(x, y, z).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5))
	);
}