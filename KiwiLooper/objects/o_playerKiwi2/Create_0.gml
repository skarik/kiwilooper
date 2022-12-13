/// @description Set up draw & camera overrides

// Inherit the parent event
event_inherited();

// Change mesh updating to follow character angles
{
	m_updateCharacterMesh = function()
	{
		xscale = 1.3;
		yscale = xscale;
		zscale = xscale;
		
		zrotation = facingDirection - 90;
	}
}

// Override the rendering function
{
	// Render defaults
	animationIndex = 0; // current frame
	mesh_frame = [];
	mesh_texture = nullptr;
	mesh_resource = null;

	// Load model
	mesh_resource = ResourceLoadModel("models/kiwi.md2");
	if (!is_undefined(mesh_resource))
	{
		ResourceAddReference(mesh_resource);
	
		mesh_frame = mesh_resource.frames;
		mesh_texture = mesh_resource.textures[0].texture_ptr;
	
		bRenderOk = (array_length(mesh_frame) > 0) && (mesh_texture != nullptr);
	}

	m_renderEvent = function()
	{
		//vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, animationRenderIndex));
		if (bRenderOk)
		{
			var finalIndex = floor(abs(animationRenderIndex)) % array_length(mesh_frame);
			var finalMesh = mesh_frame[finalIndex];
		
			vertex_submit(finalMesh, pr_trianglelist, mesh_texture);
		}
	}
}


// Set up debug camera states
{
	debug_camera_state = 0;
}