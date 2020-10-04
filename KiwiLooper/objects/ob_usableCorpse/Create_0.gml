/// @description Set up lower priority

event_inherited();

m_priority = 3; // Lowest priority of all usable
m_pickedUp = false;
height = 4;

// Set up state
image_speed = 0;
image_index = 0;

// Set up callback
m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && activatedBy.object_index == o_playerKiwi)
	{
		// TODO
	}
}

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateMesh = function()
{
	if (!m_pickedUp)
	{
		var uvs = sprite_get_uvs(sprite_index, image_index);
		meshb_BeginEdit(m_mesh);
		meshb_AddQuad(m_mesh, [
			new MBVertex(new Vector3(-0.5, -0.5, 1), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3( 0.5, -0.5, 1), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(-0.5,  0.5, 1), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
			new MBVertex(new Vector3( 0.5,  0.5, 1), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
			]);
		meshb_End(m_mesh);
	
		xscale = image_xscale * sprite_width;
		yscale = image_yscale * sprite_height;
		zrotation = image_angle;
	}
	else
	{
		// Vertical sprite matching who is holding us
	}
}
m_updateMesh(); // Update mesh now!

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}