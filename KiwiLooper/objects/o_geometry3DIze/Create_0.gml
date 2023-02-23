/// @description Set up static world rendering

// Source geometry structure
m_geometry = null;

// Meshes and textures for rendering.
m_meshes = null;
m_atlasTextures = null;

// Triangle BBox's used for optimizing collision checks.
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
	m_atlasTextures = [];
	
	// Pull the atlas information for all the materials
	var material_atlas_info = array_create(array_length(m_geometry.materials));
	for (var matIndex = 0; matIndex < array_length(material_atlas_info); ++matIndex)
	{
		var material = m_geometry.materials[matIndex];
		
		// Get the resource for the material
		var pixel_resource = null;
		if (material.type == kTextureTypeSkip || material.type == kTextureTypeClip)
		{
			pixel_resource = null; // No pixel resource to provide.
		}
		else if (material.type == kTextureTypeSpriteTileset
			|| material.type == kTextureTypeSprite)
		{
			// Find the sprite resource
			var pixel_resource = ResourceFindSpriteTexture(stl_lab0); //material.source); // issue whenever addning sprites
			if (is_undefined(pixel_resource))
			{
				pixel_resource = ResourceAddTexture(material.GetUID(), material.source);
			}
		}
		else
		{
			// Load the texture resource
			var pixel_resource = ResourceLoadTexture(material.source, GetLargestSurfaceDims(), GetLargestSurfaceDims());
		}
		
		// Find the texture in the atlas system, or add it.
		var atlas_lookup = undefined;
		if (pixel_resource != null)
		{
			atlas_lookup = AtlasFindResource(pixel_resource);
			if (is_undefined(atlas_lookup))
			{
				atlas_lookup = AtlasAddResource(pixel_resource);
			}
		}
		
		// Set up the mesh/atlas arrays now
		var drawlist_index = null;
		if (!is_undefined(atlas_lookup))
		{
			drawlist_index = array_get_index(m_atlasTextures, atlas_lookup.atlas);
			if (drawlist_index == null)
			{
				drawlist_index = array_length(m_atlasTextures);
				m_atlasTextures[drawlist_index] = atlas_lookup.atlas;
			}
		}
		
		// Set up the atlas and material information
		material_atlas_info[matIndex] = {
			uvs: is_undefined(atlas_lookup) ? [0,0,0,0] : material.GetTextureSubUVs(AtlasGet(atlas_lookup.atlas).GetUVs(atlas_lookup.index)),
			atlas_index: is_undefined(atlas_lookup) ? null : atlas_lookup.atlas,
			atlas_subindex: is_undefined(atlas_lookup) ? null : atlas_lookup.index,
			mesh_index: drawlist_index,
		};
	}
	
	// Begin all the meshes
	m_meshes = array_create(array_length(m_atlasTextures));
	for (var meshIndex = 0; meshIndex < array_length(m_meshes); ++meshIndex)
	{
		m_meshes[meshIndex] = meshb_Begin(MapGeometry_CreateVertexFormat());
	}
	
	// Let's just run through the triangles and push ALL of them for now
	m_mesh = meshb_Begin(MapGeometry_CreateVertexFormat());
	for (var tri = 0; tri < array_length(m_geometry.triangles); ++tri)
	{
		var triangle = m_geometry.triangles[tri];
		if (triangle.material == kGeoMaterialIndex_Clip)
		{
			continue; // Skip CLIP brushes from rendering.
		}
		for (var corner = 0; corner < 3; ++corner)
		{
			// Save atlas information
			triangle.vertices[corner].atlas = material_atlas_info[triangle.material].uvs;
			
			// Push the level geometry in
			MapGeometry_PushVertex(m_meshes[material_atlas_info[triangle.material].mesh_index], triangle.vertices[corner]);
		}
	}
	
	// Finish all the meshes
	for (var meshIndex = 0; meshIndex < array_length(m_meshes); ++meshIndex)
	{
		meshb_End(m_meshes[meshIndex]);
	}
}

m_renderEvent = function()
{
	if (m_mesh != null)
	{
		drawShaderStore();
		drawShaderSet(sh_editorSolidsDebug);
		for (var meshIndex = 0; meshIndex < array_length(m_meshes); ++meshIndex)
		{
			vertex_submit(m_meshes[meshIndex], pr_trianglelist, AtlasGet(m_atlasTextures[meshIndex]).GetTexture());
		}
			//vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
			// TODO:
	
		drawShaderUnstore();
	}
}