/// @description Create mesh

event_inherited();

// Set up state
image_speed = 0;
image_index = 0;

// Set up callback
m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && activatedBy.object_index == o_playerKiwi)
	{
		// Switch image
		image_index = !image_index;
		// Update the mesh
		m_updateMesh();
		
		// Now, actually toggle the target
		if (iexists(m_targetLively))
		{
			m_targetLively.m_onActivation(id);
		}
	}
}

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateMesh = function()
{
	var uvs = sprite_get_uvs(sprite_index, image_index);
	meshb_BeginEdit(m_mesh);
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(0, -0.5, 1), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0,  0.5, 1), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0, -0.5, 0), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
		new MBVertex(new Vector3(0,  0.5, 0), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
		]);
	meshb_End(m_mesh);
	
	yscale = image_xscale * sprite_width;
	zscale = image_yscale * sprite_height;
	zrotation = image_angle - 90;
}
m_updateMesh(); // Update mesh now!

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}