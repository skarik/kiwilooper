/// @description Make mesh

// Stop animation
image_speed = 0;

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

// Define the sprite update function
m_updateMesh = function()
{
	var uvs = sprite_get_uvs(sprite_index, image_index);
	m_mesh = meshb_Begin();
	meshb_AddQuad(m_mesh, [
		new MBVertex(new Vector3(-24, -24, 0), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( 24, -24, 0), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3(-24,  24, 0), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
		new MBVertex(new Vector3( 24,  24, 0), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
		]);
	meshb_End(m_mesh);
}

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}