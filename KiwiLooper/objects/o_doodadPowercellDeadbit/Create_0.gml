/// @description Set up mesh to render

event_inherited();

var uvs = sprite_get_uvs(sprite_index, image_index);

m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [
	new MBVertex(new Vector3(-0.5, -0.5, 0.7), c_white, 1.0, (new Vector2(0.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3( 0.5, -0.5, 0.7), c_white, 1.0, (new Vector2(1.0, 0.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3(-0.5,  0.5, 0.7), c_white, 1.0, (new Vector2(0.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1)),
	new MBVertex(new Vector3( 0.5,  0.5, 0.7), c_white, 1.0, (new Vector2(1.0, 1.0)).biasUVSelf(uvs), new Vector3(0, 0, 1))
	]);
meshb_End(m_mesh);

xscale = sprite_width * image_xscale;
yscale = sprite_height * image_yscale;
zrotation = image_angle;

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sprite_index, image_index));
}