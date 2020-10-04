/// @description Set up render event

// Create empty mesh
m_mesh = meshb_Begin();
meshb_AddQuad(m_mesh, [MBVertexDefault(), MBVertexDefault(), MBVertexDefault(), MBVertexDefault()]);
meshb_End(m_mesh);

update = function()
{
	// Recreate the entire mesh to render
	meshb_BeginEdit(m_mesh);
	
	var splatter_count = instance_number(ob_splatter);
	for (var i = 0; i < splatter_count; ++i)
	{
		var splatter = instance_find(ob_splatter, i);
		splatter.updated = true;
		splatter.normal = new Vector3(0, 0, 1);
		
		var uvs = sprite_get_uvs(splatter.sprite_index, splatter.image_index);
		var splatter_halfwidth = sprite_get_width(splatter.sprite_index) * 0.5;
		var splatter_halfheight = sprite_get_width(splatter.sprite_index) * 0.5;
		var splatter_angle = splatter.image_angle;
		var splatter_scale = new Vector2(splatter.image_xscale, splatter.image_yscale);
		var splatter_position = new Vector3(splatter.x, splatter.y, splatter.z);
		
		meshb_AddQuad(m_mesh, [
			new MBVertex(
				(new Vector3(-splatter_halfwidth, -splatter_halfheight, 0.5)).addSelf(splatter_position),
				c_white, 1.0,
				(new Vector2(-1.0, -1.0)).rotateSelf(splatter_angle).multiplyComponentSelf(splatter_scale).unbiasSelf().biasUVSelf(uvs),
				new Vector3(0, 0, 1)),
			new MBVertex(
				(new Vector3( splatter_halfwidth, -splatter_halfheight, 0.5)).addSelf(splatter_position),
				c_white, 1.0,
				(new Vector2(1.0, -1.0)).rotateSelf(splatter_angle).multiplyComponentSelf(splatter_scale).unbiasSelf().biasUVSelf(uvs),
				new Vector3(0, 0, 1)),
			new MBVertex(
				(new Vector3(-splatter_halfwidth,  splatter_halfheight, 0.5)).addSelf(splatter_position),
				c_white, 1.0,
				(new Vector2(-1.0, 1.0)).rotateSelf(splatter_angle).multiplyComponentSelf(splatter_scale).unbiasSelf().biasUVSelf(uvs), 
				new Vector3(0, 0, 1)),
			new MBVertex(
				(new Vector3( splatter_halfwidth,  splatter_halfheight, 0.5)).addSelf(splatter_position),
				c_white, 1.0,
				(new Vector2(1.0, 1.0)).rotateSelf(splatter_angle).multiplyComponentSelf(splatter_scale).unbiasSelf().biasUVSelf(uvs),
				new Vector3(0, 0, 1))
			]);
		
	}
	meshb_End(m_mesh);
}

m_renderEvent = function()
{
	vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_splatterBlood0, 0));
}