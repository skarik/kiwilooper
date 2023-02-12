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
// Utilities

/// @function Ui3PosScale(x, y, z)
/// @desc Gets the scale using the given position, using distance to camera and camera FoV
function Ui3PosScale(x, y, z)
{
	var camera = o_Camera3D;
	var distance_to_camera = sqrt(sqr(x - camera.x) + sqr(y - camera.y) + sqr(z - camera.z));
	var camera_vheight = sin(degtorad(o_Camera3D.fov_vertical));
	
	return (distance_to_camera * camera_vheight) / 48.0;//* 2048.0;
}

//=============================================================================
// Context

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
// Texture

#macro kUi3Texture_Text		0
#macro kUi3Texture_Rect		1
#macro kUi3Texture_Space	2

/// @function Ui3Tex_Space(context, width, height)
function Ui3Tex_Space(context, width, height)
{
	var placement_index = context.atlas.AddRect(width, height, undefined);
	var placement_uvs = context.atlas.GetUVs(placement_index);
	var placement_pos = context.atlas.GetUnscaledPosition(placement_index);
	placement_uvs[5] = kUi3Texture_Space;
	placement_uvs[6] = width;
	placement_uvs[7] = height;
	placement_uvs[8] = placement_pos[0];
	placement_uvs[9] = placement_pos[1];
	
	return placement_uvs;
}

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
	var placement_pos = context.atlas.GetUnscaledPosition(placement_index);
	placement_uvs[5] = kUi3Texture_Text;
	placement_uvs[6] = pixel_width;
	placement_uvs[7] = pixel_height;
	placement_uvs[8] = placement_pos[0];
	placement_uvs[9] = placement_pos[1];
	
	// Draw text, assuming we're using the surface now
	draw_text(placement_pos[0], placement_pos[1], text);
	
	draw_set_halign(old_halign);
	draw_set_valign(old_valign);
	
	return placement_uvs;
}

/// @function Ui3Tex_Rect(context, width, height, outline)
function Ui3Tex_Rect(context, width, height, outline)
{
	var placement_index = context.atlas.AddRect(width, height, undefined);
	var placement_uvs = context.atlas.GetUVs(placement_index);
	var placement_pos = context.atlas.GetUnscaledPosition(placement_index);
	placement_uvs[5] = kUi3Texture_Rect;
	placement_uvs[6] = width;
	placement_uvs[7] = height;
	placement_uvs[8] = placement_pos[0];
	placement_uvs[9] = placement_pos[1];
	
	DrawSpriteRectangle(placement_pos[0], placement_pos[1], placement_pos[0] + width, placement_pos[1] + height, outline);
	
	return placement_uvs;
}

/// @function Ui3Tex_TextRect(context, tex, offset_x, offset_y, text)
function Ui3Tex_TextRect(context, tex, offset_x, offset_y, text)
{
	// todo: scissor to tex
	
	draw_text(tex[8] + offset_x, tex[9] + offset_y, text);
}

/// @function Ui3Tex_RectRect(context, tex, offset_x, offset_y, width, height, outline)
function Ui3Tex_RectRect(context, tex, offset_x, offset_y, width, height, outline)
{
	// todo: scissor to tex
	
	DrawSpriteRectangle(tex[8] + offset_x, tex[9] + offset_y, tex[8] + offset_x + width, tex[9] + offset_y + height, outline);
}

/// @function Ui3Tex_LineRect(context, tex, offset_x, offset_y, offset_x2, offset_y2)
function Ui3Tex_LineRect(context, tex, offset_x, offset_y, offset_x2, offset_y2)
{
	// todo: scissor to tex
	DrawSpriteLine(tex[8] + offset_x, tex[9] + offset_y, tex[8] + offset_x2, tex[9] + offset_y2);
}

function Ui3Tex_SpriteRect(context, tex, offset_x, offset_y, sprite, index, xscale=1.0, yscale=1.0, rotation=0.0, color=c_white, alpha=1.0)
{
	// todo: scissor to tex
	
	draw_sprite_general(
		sprite, index,
		0, 0, sprite_get_width(sprite), sprite_get_height(sprite),
		tex[8] + offset_x, tex[9] + offset_y,
		xscale, yscale,
		rotation, color, color, color, color,
		alpha);
}


//=============================================================================
// Shape

/// @function Ui3Shape_Billboard(context, tex, x, y, z, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
/// @desc Makes a mesh with the given context and texture
function Ui3Shape_Billboard(context, tex, x, y, z, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
{
	var frontface_direction = Vector3FromArray(o_Camera3D.m_viewForward);
	var t_cross_x = frontface_direction.cross(Vector3FromArray(o_Camera3D.m_viewUp));
	var t_cross_y = frontface_direction.cross(t_cross_x);
	
	return Ui3Shape_Plane(context, tex, x, y, z, t_cross_x, t_cross_y, xscale, yscale, autoscale, rotation, color, alpha);
}

/// @function Ui3Shape_Plane(context, tex, x, y, z, cross_x, cross_y, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
/// @desc Makes a mesh with the given context and texture
function Ui3Shape_Plane(context, tex, x, y, z, cross_x, cross_y, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
{
	var t_cross_x = cross_x;
	var t_cross_y = cross_y;
	
	cross_x = t_cross_x.multiply(lengthdir_x(1, rotation)).add(t_cross_y.multiply(lengthdir_y(1, rotation)));
	cross_y = t_cross_y.multiply(lengthdir_x(1, rotation)).add(t_cross_x.multiply(-lengthdir_y(1, rotation)));

	if (autoscale)
	{
		var pos_scale = Ui3PosScale(x, y, z);
		xscale *= pos_scale;
		yscale *= pos_scale;
	}
	
	cross_x.normalize().multiplySelf(-tex[6] * xscale);
	cross_y.normalize().multiplySelf( tex[7] * yscale);
	
	// todo, if tex[5] is kUi3Texture_Text, then take alignment
	
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

/// @function Ui3Shape_ArcPlane(context, tex, x, y, z, cross_x, cross_y, radius, angle_start, angle_end, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
/// @desc Makes a mesh with the given context and texture
function Ui3Shape_ArcPlane(context, tex, x, y, z, cross_x, cross_y, radius, angle_start, angle_end, xscale=1.0, yscale=1.0, autoscale=false, rotation=0.0, color=c_white, alpha=1.0)
{
	var t_cross_x = cross_x;
	var t_cross_y = cross_y;
	
	cross_x = t_cross_x.multiply(lengthdir_x(1, rotation)).add(t_cross_y.multiply(lengthdir_y(1, rotation)));
	cross_y = t_cross_y.multiply(lengthdir_x(1, rotation)).add(t_cross_x.multiply(-lengthdir_y(1, rotation)));

	if (autoscale)
	{
		var pos_scale = Ui3PosScale(x, y, z);
		xscale *= pos_scale;
		yscale *= pos_scale;
	}
	
	cross_x.normalize();//.multiplySelf(-tex[6] * xscale);
	cross_y.normalize();//.multiplySelf( tex[7] * yscale);
	
	var cross_z = cross_x.cross(cross_y).normalize();
	
	// todo, if tex[5] is kUi3Texture_Text, then take alignment
	
	MeshbAddStandingFlatArc(
		context.mesh,
		color, alpha,
		-tex[7] * yscale,
		radius * xscale,
		-angle_start - 90, -angle_end - 90,
		clamp(round(abs(angle_end - angle_start) / 15), 4, 8),
		cross_x, cross_z,
		tex,
		new Vector3(x, y, z).subtract(cross_z.multiply(radius * xscale)).subtract(cross_y.multiply(tex[7]*yscale*0.5))
	);
	
	// Add the quad
	/*MeshbAddQuadUVs(
		context.mesh,
		color, alpha,
		cross_x,
		cross_y,
		tex,
		new Vector3(x, y, z).subtract(cross_x.multiply(0.5)).subtract(cross_y.multiply(0.5))
	);*/
}