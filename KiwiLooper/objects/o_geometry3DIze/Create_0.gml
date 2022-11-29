/// @description Set up static world rendering

m_geometry = null;
m_mesh = null;

m_triangleBBoxes = [];

SetGeometry = function(geometry)
{
	m_geometry = geometry;
	
	for (var i = 0; i < array_length(m_geometry.triangles); ++i)
	{
		var triangle = m_geometry.triangles[i];
		
		var triMin = new Vector3(
			min(triangle.vertices[0].position.x, triangle.vertices[1].position.x, triangle.vertices[2].position.x),
			min(triangle.vertices[0].position.y, triangle.vertices[1].position.y, triangle.vertices[2].position.y),
			min(triangle.vertices[0].position.z, triangle.vertices[1].position.z, triangle.vertices[2].position.z));
		var triMax = new Vector3(
			max(triangle.vertices[0].position.x, triangle.vertices[1].position.x, triangle.vertices[2].position.x),
			max(triangle.vertices[0].position.y, triangle.vertices[1].position.y, triangle.vertices[2].position.y),
			max(triangle.vertices[0].position.z, triangle.vertices[1].position.z, triangle.vertices[2].position.z));
		var triBBox = BBox3FromMinMax(triMin, triMax);
		
		m_triangleBBoxes[i] = triBBox;
	}
}

Initialize = function()
{
	// TODO: Create atlas
	
	// Pull the atlas information for all the materials
	var material_atlas_info = array_create(array_length(m_geometry.materials));
	for (var matIndex = 0; matIndex < array_length(material_atlas_info); ++matIndex)
	{
		material_atlas_info[matIndex] = m_geometry.materials[matIndex].GetTextureUVs();
	}
	
	// Let's just run through the triangles and push ALL of them for now
	m_mesh = meshb_Begin(MapGeometry_CreateVertexFormat());
	for (var tri = 0; tri < array_length(m_geometry.triangles); ++tri)
	{
		var triangle = m_geometry.triangles[tri];
		for (var corner = 0; corner < 3; ++corner)
		{
			// Save atlas information
			triangle.vertices[corner].atlas = material_atlas_info[triangle.material];
			
			// Push the level geometry in
			MapGeometry_PushVertex(m_mesh, triangle.vertices[corner]);
		}
	}
	meshb_End(m_mesh);
}

m_renderEvent = function()
{
	if (m_mesh != null)
	{
		var last_shader = drawShaderGet();
		drawShaderSet(sh_editorSolidsDebug);
	
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
	
		drawShaderSet(last_shader);
	}
}