//=============================================================================

function EditorSolidsUpdate()
{
	if (m_wantRebuildSolids)
	{
		m_wantRebuildSolids = false;
		
		var kUpdateCount = array_length(m_solidUpdateRequestList);
		// Empty update list? Update everything.
		if (kUpdateCount <= 0)
		{
			MapRebuildSolidsOnly();
		}
		// Update list? Update only specific objects.
		else
		{
			var renderers_will_be_updated = [];
			var solids_to_update = [];
			
			// Find unique renderers
			for (var i = 0; i < kUpdateCount; ++i)
			{
				var solid_id_to_update = m_solidUpdateRequestList[i];
				var solid_renderer_to_update = solid_to_renderer[?solid_id_to_update];
				if (!array_contains(renderers_will_be_updated, solid_renderer_to_update))
				{
					array_push(renderers_will_be_updated, solid_renderer_to_update);
					array_push(solids_to_update, solid_id_to_update);
				}
			}
			
			// Update unique renderers
			for (var i = 0; i < array_length(solids_to_update); ++i)
			{
				EditorSolidsRendererRecreate(solids_to_update[i]);
			}
		}
	}
}

function EditorSolidsRendererFree()
{
	for (var i = 0; i < array_length(solidRenderers); ++i)
	{
		var solidsRenderer = solidRenderers[i];
		if (solidsRenderer != null && iexists(solidsRenderer))
		{
			for (var meshIndex = 0; meshIndex < array_length(solidsRenderer.m_renderList); ++meshIndex)
			{
				meshB_Cleanup(solidsRenderer.m_renderList[meshIndex].mesh);
			}
			idelete(solidsRenderer);
		}
	}
	solidRenderers = [];
	
	// Don't free the texture map: we want to keep that map around.
	
	// Since we destroyed the renderers, we definitely clear that map
	if (ds_exists(solid_to_renderer, ds_type_map))
	{
		ds_map_destroy(solid_to_renderer);
		solid_to_renderer = null;
	}
}
//=============================================================================

function EditorSolidsRendererDeclare()
{
	solidRenderers = [];
	texture_to_atlas = null;
	solid_to_renderer = null;
}
function EditorSolidsRendererEnd()
{
	// Clear out texture map now.
	if (ds_exists(texture_to_atlas, ds_type_map))
	{
		ds_map_destroy(texture_to_atlas);
		texture_to_atlas = null;
	}
}

function EditorSolidsRendererRecreate(solid_id)
{
	debugLog(kLogVerbose, "Recreating single editor solid.");
	
	var solidRenderer = solid_to_renderer[?solid_id];
	if (!is_undefined(solidRenderer))
	{
		// Free the mesh first.
		for (var meshIndex = 0; meshIndex < array_length(solidRenderer.m_renderList); ++meshIndex)
		{
			meshB_Cleanup(solidRenderer.m_renderList[meshIndex].mesh);
		}
		
		// Collect all the textures
		for (var internalSolidIndex = 0; internalSolidIndex < array_length(solidRenderer.m_solids); ++internalSolidIndex)
		{
			var mapSolid = m_state.map.solids[solidRenderer.m_solids[internalSolidIndex]];
			for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
			{
				var face = mapSolid.faces[faceIndex];
				face.texture.BuildUID(); // Since we can't be sure if its up-to-date, we force rebuilding it
			
				// Is this already in our atlases?
				var atlas_id = texture_to_atlas[?face.texture.GetUID()];
				if (is_undefined(atlas_id))
				{
					// if not, find an atlas to add it to
					if (face.texture.type == kTextureTypeSpriteTileset
						|| face.texture.type == kTextureTypeSprite)
					{
						// Find the sprite resource
						var sprite_resource = ResourceFindSpriteTexture(face.texture.source);
						if (is_undefined(sprite_resource))
						{
							sprite_resource = ResourceAddTexture(face.texture.GetUID(), face.texture.source);
						}

						// Add sprite to atlas & store it
						var atlas_id = AtlasAddResource(sprite_resource);
						texture_to_atlas[?face.texture.GetUID()] = atlas_id;
					}
					else
					{
						// Load the texture resource
						var texture_resource = ResourceLoadTexture(face.texture.source, GetLargestSurfaceDims(), GetLargestSurfaceDims());
						// Add the texture to the atlas
						var atlas_id = AtlasAddResource(texture_resource);
						texture_to_atlas[?face.texture.GetUID()] = atlas_id;
					}
				}
			}
		}
		
		// Set up mesh building stuff
		var uniqueAtlasCount = 0;
		var meshes = [];
		var atlases = [];
		
		// Now, loop through the solids and build the mesh
		for (var internalSolidIndex = 0; internalSolidIndex < array_length(solidRenderer.m_solids); ++internalSolidIndex)
		{
			var mapSolid = m_state.map.solids[solidRenderer.m_solids[internalSolidIndex]];
			
			// TODO: This internal loop is the same as elsewhere.
			for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
			{
				var face = mapSolid.faces[faceIndex];
				var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
				// Let's get the texture info & target mesh for this face
				var atlas_current_tex_and_atlas = texture_to_atlas[?face.texture.GetUID()];
				var atlas_current = atlas_current_tex_and_atlas.atlas;
				// Find the matching atlas in the atlases
				var mesh_and_atlas_index = array_get_index(atlases, atlas_current);
				if (mesh_and_atlas_index == null)
				{
					mesh_and_atlas_index = array_length(atlases);
					// if no match -> add atlas & mesh
					meshes[mesh_and_atlas_index] = meshb_Begin(MapGeometry_CreateVertexFormat());
					atlases[mesh_and_atlas_index] = atlas_current;
					uniqueAtlasCount += 1;
				}
			
				// Set up current mesh
				var mesh_current = meshes[mesh_and_atlas_index];
			
				// Now build the mesh like the old method:
				{
					// Get the atlas UVs used for this face
					var atlasInfo = AtlasGet(atlas_current).GetUVs(atlas_current_tex_and_atlas.index);
					atlasInfo = face.texture.GetTextureSubUVs(atlasInfo);
					
					// Get the original size for this texture (important for the UVs)
					var scaleInfo = AtlasGet(atlas_current).GetUnscaledSize(atlas_current_tex_and_atlas.index);
			
					// Create a plane for calculating UVs
					var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
			
					// Now grab the vertices
					var faceMesh = array_create(array_length(triangleList) * 3);
					for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
					{
						var triIndices = triangleList[triangleIndex];
				
						// Set up the positions & uvs
						for (var triCorner = 0; triCorner < 3; ++triCorner)
						{
							var solidVertex = mapSolid.vertices[triIndices[triCorner]];
					
							var meshVert = MBVertexDefault();
					
							// Get position
							meshVert.position.x = solidVertex.position.x;
							meshVert.position.y = solidVertex.position.y;
							meshVert.position.z = solidVertex.position.z;
					
							// Get UVs
							var uvPoint = facePlane.flattenPoint(solidVertex.position);
							face.uvinfo.TransformPoint(uvPoint, face.texture, scaleInfo);
					
							meshVert.uv.x = uvPoint.x;
							meshVert.uv.y = uvPoint.y;
					
							// Save our new vertex!
							faceMesh[triangleIndex * 3 + triCorner] = meshVert;
						}
				
						// Calculate normal for this triangle
						var faceNormal = TriangleGetNormal([Vector3FromTranslation(faceMesh[0].position), Vector3FromTranslation(faceMesh[1].position), Vector3FromTranslation(faceMesh[2].position)]);
				
						// Write normals + uvs
						for (var i = 0; i < 3; ++i)
						{
							faceMesh[triangleIndex * 3 + i].normal.x = faceNormal.x;
							faceMesh[triangleIndex * 3 + i].normal.y = faceNormal.y;
							faceMesh[triangleIndex * 3 + i].normal.z = faceNormal.z;
					
							faceMesh[triangleIndex * 3 + i].atlas = atlasInfo;
						}
					}
					// Now that everything fixed up, add the tri
					for (var i = 0; i < array_length(faceMesh); ++i)
					{
						MapGeometry_PushVertex(mesh_current, faceMesh[i]);
					}
				}
			}
		}
		
		// Finish up all the meshes we've begun
		for (var i = 0; i < uniqueAtlasCount; ++i)
		{
			meshb_End(meshes[i]);
		}
		
		// Save the new meshes to the solids renderer
		solidRenderer.m_renderList = array_create(uniqueAtlasCount);
		for (var i = 0; i < uniqueAtlasCount; ++i)
		{
			solidRenderer.m_renderList[i] = {
				mesh: meshes[i],
				atlas: atlases[i],
			};
		}
	}
	else
	{
		debugLog(kLogError, "Solid renderer for solid#" + string(solid_id) + " missing");
	}
}

function EditorSolidsRendererCreate()
{
	debugLog(kLogVerbose, "Recreating all editor solids.");
	
	solidRenderers = [];
	if (!ds_exists(texture_to_atlas, ds_type_map))
	{
		texture_to_atlas = ds_map_create();
	}
	
	// Create the solids map
	solid_to_renderer = ds_map_create();
	
	// First off, set up atlases:
	// collect all the textures
	for (var solidIndex = 0; solidIndex < array_length(m_state.map.solids); ++solidIndex)
	{
		var mapSolid = m_state.map.solids[solidIndex];
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			var face = mapSolid.faces[faceIndex];
			face.texture.BuildUID(); // Since we can't be sure if its up-to-date, we force rebuilding it
			
			// Is this already in our atlases?
			var atlas_id = texture_to_atlas[?face.texture.GetUID()];
			if (is_undefined(atlas_id))
			{
				// if not, find an atlas to add it to
				if (face.texture.type == kTextureTypeSpriteTileset
					|| face.texture.type == kTextureTypeSprite)
				{
					// Find the sprite resource
					var sprite_resource = ResourceFindSpriteTexture(face.texture.source);
					if (is_undefined(sprite_resource))
					{
						sprite_resource = ResourceAddTexture(face.texture.GetUID(), face.texture.source);
					}

					// Add sprite to atlas & store it
					var atlas_id = AtlasAddResource(sprite_resource);
					texture_to_atlas[?face.texture.GetUID()] = atlas_id;
				}
				else
				{
					// Load the texture resource
					var texture_resource = ResourceLoadTexture(face.texture.source, GetLargestSurfaceDims(), GetLargestSurfaceDims());
					// Add the texture to the atlas
					var atlas_id = AtlasAddResource(texture_resource);
					texture_to_atlas[?face.texture.GetUID()] = atlas_id;
				}
			}
		}
	}
	
	// Now, let's loop through the solids.
	static kMaxSolidsPerRenderer = 6;
	
	var kSolidCount = array_length(m_state.map.solids);
	var solidCounter = 0;
	var uniqueAtlasCount = 0;
	var meshes = [];
	var atlases = [];
	var solids = [];
	for (var solidIndex = 0; solidIndex < kSolidCount; ++solidIndex)
	{
		var mapSolid = m_state.map.solids[solidIndex];
		array_push(solids, solidIndex);
		
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			var face = mapSolid.faces[faceIndex];
			var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
			// Let's get the texture info & target mesh for this face
			var atlas_current_tex_and_atlas = texture_to_atlas[?face.texture.GetUID()];
			var atlas_current = atlas_current_tex_and_atlas.atlas;
			// Find the matching atlas in the atlases
			var mesh_and_atlas_index = array_get_index(atlases, atlas_current);
			if (mesh_and_atlas_index == null)
			{
				mesh_and_atlas_index = array_length(atlases);
				// if no match -> add atlas & mesh
				meshes[mesh_and_atlas_index] = meshb_Begin(MapGeometry_CreateVertexFormat());
				atlases[mesh_and_atlas_index] = atlas_current;
				uniqueAtlasCount += 1;
			}
			
			// Set up current mesh
			var mesh_current = meshes[mesh_and_atlas_index];
			
			// Now build the mesh like the old method:
			{
				// Get the atlas UVs used for this face
				var atlasInfo = AtlasGet(atlas_current).GetUVs(atlas_current_tex_and_atlas.index);
				atlasInfo = face.texture.GetTextureSubUVs(atlasInfo);
				
				// Get the original size for this texture (important for the UVs)
				var scaleInfo = AtlasGet(atlas_current).GetUnscaledSize(atlas_current_tex_and_atlas.index);
			
				// Create a plane for calculating UVs
				var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
			
				// Now grab the vertices
				var faceMesh = array_create(array_length(triangleList) * 3);
				for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
				{
					var triIndices = triangleList[triangleIndex];
				
					// Set up the positions & uvs
					for (var triCorner = 0; triCorner < 3; ++triCorner)
					{
						var solidVertex = mapSolid.vertices[triIndices[triCorner]];
					
						var meshVert = MBVertexDefault();
					
						// Get position
						meshVert.position.x = solidVertex.position.x;
						meshVert.position.y = solidVertex.position.y;
						meshVert.position.z = solidVertex.position.z;
					
						// Get UVs
						var uvPoint = facePlane.flattenPoint(solidVertex.position);
						face.uvinfo.TransformPoint(uvPoint, face.texture, scaleInfo);
					
						meshVert.uv.x = uvPoint.x;
						meshVert.uv.y = uvPoint.y;
					
						// Save our new vertex!
						faceMesh[triangleIndex * 3 + triCorner] = meshVert;
					}
				
					// Calculate normal for this triangle
					var faceNormal = TriangleGetNormal([Vector3FromTranslation(faceMesh[0].position), Vector3FromTranslation(faceMesh[1].position), Vector3FromTranslation(faceMesh[2].position)]);
				
					// Write normals + uvs
					for (var i = 0; i < 3; ++i)
					{
						faceMesh[triangleIndex * 3 + i].normal.x = faceNormal.x;
						faceMesh[triangleIndex * 3 + i].normal.y = faceNormal.y;
						faceMesh[triangleIndex * 3 + i].normal.z = faceNormal.z;
					
						faceMesh[triangleIndex * 3 + i].atlas = atlasInfo;
					}
				}
				// Now that everything fixed up, add the tri
				for (var i = 0; i < array_length(faceMesh); ++i)
				{
					MapGeometry_PushVertex(mesh_current, faceMesh[i]);
				}
			}
		}
		
		solidCounter += 1;
		if (solidCounter >= kMaxSolidsPerRenderer || solidIndex + 1 == kSolidCount)
		{
			// Finish up all the meshes we've begun
			for (var i = 0; i < uniqueAtlasCount; ++i)
			{
				meshb_End(meshes[i]);
			}
			
			// Let's set up our renderer for this group:
			var solidRenderer = inew(ob_3DObject);
			solidRenderer.lit = true;
			solidRenderer.m_renderEvent = method(solidRenderer, function()
			{
				drawShaderStore();
				drawShaderSet(sh_editorSolidsDebug);
				for (var i = 0; i < array_length(m_renderList); ++i)
				{
					var vbuffer = m_renderList[i].mesh;
					var texture = AtlasGet(m_renderList[i].atlas).GetTexture();
					vertex_submit(vbuffer, pr_trianglelist, texture);
				}
				drawShaderUnstore();
			});
			
			// Give the solid stuff to render
			solidRenderer.m_renderList = array_create(uniqueAtlasCount);
			for (var i = 0; i < uniqueAtlasCount; ++i)
			{
				solidRenderer.m_renderList[i] = {
					mesh: meshes[i],
					atlas: atlases[i],
				};
			}
			
			// Save the solids this renderer is using
			solidRenderer.m_solids = solids;
			for (var i = 0; i < array_length(solids); ++i)
			{
				solid_to_renderer[?solids[i]] = solidRenderer;
			}
			
			// Save the renderer to our list
			array_push(solidRenderers, solidRenderer);
			
			// Reset solid counter
			solidCounter = 0;
			uniqueAtlasCount = 0;
			meshes = [];
			atlases = [];
			solids = [];
		}
	}
	
	/*var mesh = meshb_Begin(MapGeometry_CreateVertexFormat());
	for (var solidIndex = 0; solidIndex < array_length(m_state.map.solids); ++solidIndex)
	{
		var mapSolid = m_state.map.solids[solidIndex];
		for (var faceIndex = 0; faceIndex < array_length(mapSolid.faces); ++faceIndex)
		{
			var face = mapSolid.faces[faceIndex];
			var triangleList = mapSolid.TriangulateFace(faceIndex, false);
			
			// Get the atlas UVs used for this face
			var atlasInfo = face.texture.GetTextureUVs();
			
			// Create a plane for calculating UVs
			var facePlane = Plane3FromNormalOffset(face.uvinfo.normal, new Vector3(0, 0, 0));
			
			// Now grab the vertices
			var faceMesh = array_create(array_length(triangleList) * 3);
			for (var triangleIndex = 0; triangleIndex < array_length(triangleList); ++triangleIndex)
			{
				var triIndices = triangleList[triangleIndex];
				
				// Set up the positions & uvs
				for (var triCorner = 0; triCorner < 3; ++triCorner)
				{
					var solidVertex = mapSolid.vertices[triIndices[triCorner]];
					
					var meshVert = MBVertexDefault();
					
					// Get position
					meshVert.position.x = solidVertex.position.x;
					meshVert.position.y = solidVertex.position.y;
					meshVert.position.z = solidVertex.position.z;
					
					// Get UVs
					var uvPoint = facePlane.flattenPoint(solidVertex.position);
					face.uvinfo.TransformPoint(uvPoint, face.texture);
					
					meshVert.uv.x = uvPoint.x;
					meshVert.uv.y = uvPoint.y;
					
					// Save our new vertex!
					faceMesh[triangleIndex * 3 + triCorner] = meshVert;
				}
				
				// Calculate normal for this triangle
				var faceNormal = TriangleGetNormal([Vector3FromTranslation(faceMesh[0].position), Vector3FromTranslation(faceMesh[1].position), Vector3FromTranslation(faceMesh[2].position)]);
				
				// Write normals + uvs
				for (var i = 0; i < 3; ++i)
				{
					faceMesh[triangleIndex * 3 + i].normal.x = faceNormal.x;
					faceMesh[triangleIndex * 3 + i].normal.y = faceNormal.y;
					faceMesh[triangleIndex * 3 + i].normal.z = faceNormal.z;
					
					faceMesh[triangleIndex * 3 + i].atlas = atlasInfo;
				}
			}
			// Now that everything fixed up, add the tri
			//meshb_AddTris(mesh, faceMesh);
			for (var i = 0; i < array_length(faceMesh); ++i)
			{
				MapGeometry_PushVertex(mesh, faceMesh[i]);
			}
		}
	}
	
	meshb_End(mesh);
	
	solidsRenderer.m_mesh = mesh;
	solidsRenderer.m_renderEvent = method(solidsRenderer, function()
	{
		var shaderPrev = drawShaderGet();
		drawShaderSet(sh_editorSolidsDebug);
		
			vertex_submit(m_mesh, pr_trianglelist, sprite_get_texture(stl_lab0, 0));
			
		drawShaderSet(shaderPrev);
	});*/
}