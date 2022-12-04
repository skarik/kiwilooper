/// @description Set up render event

m_mesh = null;

m_renderEvent = function()
{
	static m_editorLineEdge_uLineColor = shader_get_uniform(sh_editorLineEdge, "uLineColor");
	static m_editorLineEdge_uLineSizeAndFade = shader_get_uniform(sh_editorLineEdge, "uLineSizeAndFade");
	
	static m_editorFlatShaded_uFlatColor = shader_get_uniform(sh_editorFlatShaded, "uFlatColor");
	
	if (m_mesh != null)
	{
		drawShaderStore();
		drawShaderSet(sh_editorLineEdge);
	
			shader_set_uniform_f(m_editorLineEdge_uLineSizeAndFade, 0.5, 0, 0, 0);
			shader_set_uniform_f(m_editorLineEdge_uLineColor,
				color_get_red(image_blend) / 255.0,
				color_get_green(image_blend) / 255.0,
				color_get_blue(image_blend) / 255.0,
				image_alpha);
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(sfx_square, 0));
	
		drawShaderUnstore();	
	}
}