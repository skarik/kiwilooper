/// @description Set up rendering & character basics

Character_Create();

controlInit();

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateCharacterMesh = function()
{
	var uvs = sprite_get_uvs(sprite_index, animationRenderIndex);
	var top = sprite_get_yoffset(sprite_index) / sprite_get_height(sprite_index);
	var bot = top - 1.0;
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
		zscale = image_yscale * sprite_height / lerp(lengthdir_x(1, o_Camera3D.yrotation), 1.0, 0.1);
		zrotation = o_Camera3D.zrotation;
	}
}
m_updateCharacterMesh(); // Update mesh now!

// Define the rendering function
m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, animationRenderIndex));
}