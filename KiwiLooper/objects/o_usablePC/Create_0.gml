/// @description Create mesh

event_inherited();

// Set up state
image_speed = 0;
image_index = 0;

// Set up callback
m_onActivation = function(activatedBy)
{
	if (iexists(activatedBy) && Game_IsPlayer_safe(activatedBy))
	{
		// Switch image
		image_index = !image_index;
		// Update the mesh
		m_updateMesh();
		
		// Now, actually toggle the target
		if (iexists(m_targetLively))
		{
			m_targetLively.m_onActivation(id);
			sound_play_at(x, y, z, "sound/door/button0.wav");
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
	var width = image_xscale * sprite_width * 0.5;
	var height = image_yscale * sprite_height;
	
	var uvs = sprite_get_uvs(sprite_index, image_index);
	meshb_BeginEdit(m_mesh);
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(0, -width, height), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0,  width, height), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0, -width, 0), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
		new MBVertex(new Vector3(0,  width, 0), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
		]);
	meshb_End(m_mesh);
}
m_updateMesh(); // Update mesh now!

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}

// Update rotation on load
onPostLevelLoad = function()
{
	zrotation = image_angle - 90;
}
