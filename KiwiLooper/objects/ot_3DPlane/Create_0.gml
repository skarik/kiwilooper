/// @description Make mesh

var uvs = sprite_get_uvs(ssy_power, 0);

m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [
	new MBVertex(new Vector3(-32, -32, 0), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3( 32, -32, 0), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3(-32,  32, 0), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3( 32,  32, 0), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
	]);
meshb_End(m_mesh);

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(ssy_power, 0));
}