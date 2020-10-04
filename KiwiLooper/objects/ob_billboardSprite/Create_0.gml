/// @description Set up rendering

// Set default animation speed
image_speed = 0;
animationIndex = 0.0;
animationSpeed = 15.0;
killOnEnd = false;

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateMesh = function()
{
	if (!sprite_exists(sprite_index))
	{
		return;
	}
	
	var uvs = sprite_get_uvs(sprite_index, killOnEnd ? clamp(animationIndex, 0.0, image_number - 1) : animationIndex);
	var top = 0.5;
	var bot = -0.5;
	meshb_BeginEdit(m_mesh);
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(0, -0.5, top), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0,  0.5, top), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(0, -0.5, bot), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0)),
		new MBVertex(new Vector3(0,  0.5, bot), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 1, 0))
		]);
	meshb_End(m_mesh);
	
	if (iexists(o_Camera3D))
	{
		yscale = image_xscale * sprite_width;
		zscale = image_yscale * sprite_height;// / lerp(lengthdir_x(1, o_Camera3D.yrotation), 1.0, 0.1);
		zrotation = o_Camera3D.zrotation;
		yrotation = -o_Camera3D.yrotation;
	}
}
m_updateMesh(); // Update mesh now!

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, killOnEnd ? clamp(animationIndex, 0.0, image_number - 1) : animationIndex));
}