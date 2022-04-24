/// @description Set up rendering

// Set default animation speed
animationIndex	= 0.0;
animationSpeed	= 15.0;
killOnEnd		= false;

// Set up GM state
image_speed = 0;

// Set up last frame
m_lastFrame = null;
d_xscale = 1.0;
d_yscale = 1.0;

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

m_updateMesh = function()
{
	// If have no sprite, don't make a mesh.
	if (!sprite_exists(sprite_index))
	{
		return;
	}
	
	// If frame has changed, update the mesh:
	var next_frame = floor(killOnEnd ? clamp(animationIndex, 0.0, image_number - 1) : animationIndex);
	if (true||m_lastFrame != next_frame) //TODO: fix
	{
		var uvs = sprite_get_uvs(sprite_index, next_frame);
		var top = 0.5 * d_yscale;
		var bot = -0.5 * d_yscale;
		var left = -0.5 * d_xscale;
		var right = 0.5 * d_xscale;
		meshb_BeginEdit(m_mesh);
		meshb_AddQuad(m_mesh, [
			new MBVertex(new Vector3(0,  left, top), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(0, right, top), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
			new MBVertex(new Vector3(0,  left, bot), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
			new MBVertex(new Vector3(0, right, bot), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
			]);
		meshb_End(m_mesh);
		
		m_lastFrame = next_frame;
	}
};

m_updateOrientation = function()
{
	if (iexists(o_Camera3D))
	{
		d_xscale = image_xscale * sprite_width;
		d_yscale = image_yscale * sprite_height;
		zrotation = o_Camera3D.zrotation;
		yrotation = -o_Camera3D.yrotation;
	}
};

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, m_lastFrame));
};

// Everything is now defined & ready!
// Update mesh now!
m_updateOrientation();
m_updateMesh();
